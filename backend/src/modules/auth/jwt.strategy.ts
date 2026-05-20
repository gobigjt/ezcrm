import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { DatabaseService } from '../../database/database.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly db: DatabaseService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'secret',
    });
  }

  async validate(payload: any) {
    if (!payload?.id) throw new UnauthorizedException();
    let tenantId: number | null = payload.tenant_id ?? null;
    // Old tokens may have been issued without tenant_id — fall back to DB lookup.
    if (tenantId === null && String(payload.role || '').trim().toLowerCase() !== 'super admin') {
      const res = await this.db.query(
        'SELECT tenant_id FROM users WHERE id=$1 AND is_active=TRUE LIMIT 1',
        [payload.id],
      );
      tenantId = res.rows[0]?.tenant_id ?? null;
    }
    return {
      id: payload.id,
      email: payload.email,
      role: payload.role,
      role_id: payload.role_id,
      tenant_id: tenantId,
    };
  }
}
