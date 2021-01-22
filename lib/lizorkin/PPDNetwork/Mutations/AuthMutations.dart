String makeOTP = """
mutation MakeOTP(\$phone: PhoneNumber!) {
  makeOTP(phone: \$phone) {
    newUser {
      state
    } 
    nextBackoffTime
    oneTimeLogin
  }
}
""";


String otpToToken = """
mutation OtpToToken(\$login: String!, \$password: String!) {
  otpToToken(login: \$login, password: \$password) {
    expiration
    expiration_date
    token
  }
}
""";