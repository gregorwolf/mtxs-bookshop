using {cuid, } from '@sap/cds/common';

type TextDictionary : array of String;

type Integrations {
  urlTemplateId          : String;
  urlTemplateParams      : UrlTemplateParams;
  urlTemplateDestination : String;
}

type UrlTemplateParams {
  appId          : String;
  semanticObject : String;
  action         : String;
}

type InboundSignatureParameters {
  ![sap-ach]      : {
    required      : Boolean;
    defaultValue  : {
      value       : String;
      format      : String;
    };
  };
  ![sap-fiori-id] : {
    required      : Boolean;
    defaultValue  : {
      value       : String;
      format      : String;
    };
  };
}

type Inbounds {
  action         : String;
  semanticObject : String;
  signature      : InboundSignatureParameters;
  deviceTypes    : {
    desktop      : Boolean;
    tablet       : Boolean;
    phone        : Boolean;
  };
  title          : String;
}

type CrossNavigation {
  inbounds : Inbounds;
}

type SapApp {
  crossNavigation : CrossNavigation;
}

type CommonAppConfig {
  sap_app           : {
    ach             : String;
  };
  sap_fiori         : {
    registrationIds : array of String;
  };
}

type Visualizations : array of String;

type TargetAppConfig {
  sap_integrations : array of Integrations;
  sap_app          : SapApp;
  sap_ui           : {
    technology     : String;
  };
}

type Payload {
  visualizations  : Visualizations;
  targetAppConfig : TargetAppConfig;
  commonAppConfig : CommonAppConfig;
}

type Texts {
  locale         : String;
  textDictionary : TextDictionary;
}

entity Entity : cuid {
  _version       : String;
  identification : {
    id         : String;
    entityType : String;
    title      : String;
  };
  payload        : Payload;
  texts          : array of Texts;
}

@protocol: 'rest'
service FlpContentExposureService {

  entity entities as projection on Entity;

}
