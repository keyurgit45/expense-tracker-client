import 'package:dartz/dartz.dart';

import '../errors/failures.dart';

class InputConverter {
  Either<Failure, int> stringToUnsignedInteger(String str) {
    try {
      final integer = int.parse(str);
      if (integer < 0) {
        return const Left(ValidationFailure(message: 'Number must be positive'));
      }
      return Right(integer);
    } on FormatException {
      return const Left(ValidationFailure(message: 'Invalid number format'));
    }
  }

  Either<Failure, double> stringToDouble(String str) {
    try {
      final value = double.parse(str);
      return Right(value);
    } on FormatException {
      return const Left(ValidationFailure(message: 'Invalid number format'));
    }
  }

  Either<Failure, double> stringToPositiveDouble(String str) {
    try {
      final value = double.parse(str);
      if (value <= 0) {
        return const Left(ValidationFailure(message: 'Number must be positive'));
      }
      return Right(value);
    } on FormatException {
      return const Left(ValidationFailure(message: 'Invalid number format'));
    }
  }
}