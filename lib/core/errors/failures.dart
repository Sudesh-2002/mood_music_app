import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object> get props => [message];
}

class AuthFailure extends Failure { const AuthFailure(super.message); }
class NetworkFailure extends Failure { const NetworkFailure(super.message); }
class CameraFailure extends Failure { const CameraFailure(super.message); }
class ModelFailure extends Failure { const ModelFailure(super.message); }
class MusicSourceFailure extends Failure { const MusicSourceFailure(super.message); }
class CacheFailure extends Failure { const CacheFailure(super.message); }