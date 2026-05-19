import { Module }                    from '@nestjs/common';
import { NotificationsController }   from './notifications.controller';
import { NotificationsService }      from './notifications.service';
import { DatabaseModule }            from '../../database/database.module';
import { FcmPushService } from './fcm-push.service';
import { WebPushService } from './web-push.service';

@Module({
  imports:     [DatabaseModule],
  controllers: [NotificationsController],
  providers:   [NotificationsService, FcmPushService, WebPushService],
  exports:     [NotificationsService, FcmPushService, WebPushService],
})
export class NotificationsModule {}
