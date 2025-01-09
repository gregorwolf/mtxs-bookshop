using {sap.eventqueue.Event as Event} from '@cap-js-community/event-queue';

@(requires: 'admin')
service AdminService {

  entity Events as projection on Event;

}
