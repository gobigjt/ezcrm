import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsBoolean, IsNotEmpty, IsNumber, IsOptional, IsString, Matches, MaxLength, Min } from 'class-validator';

export class CreateTenantDto {
  @ApiProperty({ example: 'Acme Industries' })
  @IsNotEmpty()
  @MaxLength(200)
  name: string;

  @ApiPropertyOptional({
    example: 'acme-industries',
    description: 'Lowercase kebab-case slug. If omitted, derived from name.',
  })
  @IsOptional()
  @Matches(/^[a-z0-9]+(?:-[a-z0-9]+)*$/, {
    message: 'slug must be lowercase kebab-case',
  })
  slug?: string;

  @ApiPropertyOptional({ example: true, default: true })
  @IsOptional()
  @IsBoolean()
  is_active?: boolean;

  @ApiPropertyOptional({ example: 'Admin@123', description: 'Password for the auto-created Admin user. Defaults to Admin@123.' })
  @IsOptional()
  @IsString()
  admin_password?: string;

  @ApiPropertyOptional({ example: 0, description: 'Max users allowed for this tenant. 0 means unlimited.' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  max_users?: number;
}
