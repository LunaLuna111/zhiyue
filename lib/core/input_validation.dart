bool isDecimalContentId(String value) =>
    RegExp(r'^[0-9]{1,32}$').hasMatch(value);

bool isColumnToken(String value) =>
    RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(value);
