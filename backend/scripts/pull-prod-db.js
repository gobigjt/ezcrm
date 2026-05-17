// Pull production DB data into local DB
// Usage: node scripts/pull-prod-db.js

require('dotenv').config();
const { Client } = require('pg');

const PROD_URL = 'postgresql://postgres:uzWoxECVboOUqVEknZfLFnmyHqkZwejM@roundhouse.proxy.rlwy.net:53348/railway';
const LOCAL_URL = process.env.DATABASE_URL;

async function getTables(client) {
  const res = await client.query(`
    SELECT tablename FROM pg_tables
    WHERE schemaname = 'public'
    AND tablename != 'schema_migrations'
    ORDER BY tablename
  `);
  return res.rows.map(r => r.tablename);
}

async function main() {
  const prod = new Client({ connectionString: PROD_URL, ssl: { rejectUnauthorized: false } });
  const local = new Client({ connectionString: LOCAL_URL });

  console.log('Connecting to production...');
  await prod.connect();
  console.log('Connecting to local...');
  await local.connect();

  const tables = await getTables(prod);
  console.log(`Found ${tables.length} tables: ${tables.join(', ')}\n`);

  // Disable FK constraints
  await local.query('SET session_replication_role = replica');

  // Truncate ALL tables at once to avoid cascade ordering issues
  console.log('Truncating local tables...');
  await local.query(`TRUNCATE TABLE ${tables.map(t => `"${t}"`).join(', ')} RESTART IDENTITY`);

  // Fetch all data from prod first, then insert
  for (const table of tables) {
    process.stdout.write(`  Copying ${table}... `);
    try {
      const { rows, fields } = await prod.query(`SELECT * FROM "${table}"`);
      if (rows.length === 0) {
        console.log('empty');
        continue;
      }

      const cols = fields.map(f => `"${f.name}"`).join(', ');
      const batchSize = 500;
      for (let i = 0; i < rows.length; i += batchSize) {
        const batch = rows.slice(i, i + batchSize);
        const values = batch.map((row, ri) => {
          const placeholders = fields.map((_, fi) => `$${ri * fields.length + fi + 1}`).join(', ');
          return `(${placeholders})`;
        }).join(', ');
        const params = batch.flatMap(row => fields.map(f => row[f.name]));
        await local.query(`INSERT INTO "${table}" (${cols}) VALUES ${values}`, params);
      }

      console.log(`${rows.length} rows`);
    } catch (err) {
      console.log(`SKIPPED (${err.message})`);
    }
  }

  // Re-enable triggers
  await local.query('SET session_replication_role = DEFAULT');

  // Reset sequences
  console.log('\nResetting sequences...');
  const seqRes = await local.query(`
    SELECT sequence_name FROM information_schema.sequences
    WHERE sequence_schema = 'public'
  `);
  for (const { sequence_name } of seqRes.rows) {
    try {
      await local.query(`SELECT setval('${sequence_name}', COALESCE((SELECT MAX(id) FROM "${sequence_name.replace('_id_seq','').replace('_seq','')}"), 1))`);
    } catch { /* ignore */ }
  }

  await prod.end();
  await local.end();
  console.log('\nDone! Production data is now in your local DB.');
}

main().catch(err => { console.error(err.message); process.exit(1); });
