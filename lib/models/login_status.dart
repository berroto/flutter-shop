enum LoginStatus {
  NewPasswordRequired,
  MFARequired,
  SelectMFA,
  MFASetup,
  UserTotpRequired,
  CustomChallengeRequired,
  ConfirmationRequired,
  ClientException,
  LoginError,
  Unknown
}