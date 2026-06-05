require('dotenv').config();
const { Client } = require('pg');
const fs = require('fs');
(async () => {
  const client = new Client({ connectionString: process.env.DATABASE_URL });
  await client.connect();
  try {
    const table = 'leads';
    const ts = new Date().toISOString().replace(/[:.]/g, '_');
    const outPath = `backups/leads_dump_${ts}.sql`;

    const colRes = await client.query(`SELECT column_name FROM information_schema.columns WHERE table_schema='public' AND table_name=$1 ORDER BY ordinal_position`, [table]);
    const cols = colRes.rows.map(r => r.column_name);

    const res = await client.query(`SELECT * FROM "${table}"`);

    const stream = fs.createWriteStream(outPath, { encoding: 'utf8' });
    stream.write(`-- Dump of table ${table} at ${new Date().toISOString()}\n`);
    stream.write('BEGIN;\n');
    stream.write(`DELETE FROM \"${table}\";\n`);

    for (const row of res.rows) {
      const values = cols.map(c => {
        const v = row[c];
        if (v === null || v === undefined) return 'NULL';
        if (typeof v === 'number' || typeof v === 'bigint') return v.toString();
        // escape single quotes
        return `'${String(v).replace(/'/g, "''").replace(/\\/g, "\\\\")}'`;
      });
      stream.write(`INSERT INTO \"${table}\" (${cols.map(c=>`\"${c}\"`).join(', ')}) VALUES (${values.join(', ')});\n`);
    }

    stream.write('COMMIT;\n');
    stream.end();
    console.log('Created:', outPath);
  } catch (err) {
    console.error(err.message);
    process.exit(1);
  } finally {
    await client.end();
  }
})();
