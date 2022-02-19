import Int8 "mo:base/Int8";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Blob "mo:base/Blob";
import Heap "mo:base/Heap";

module Types {
  public type TaskId = Nat64;

  public type Task = {
    data: Text;
  };

  public type Iterations = {
    #Infinite;
    #Exact: Nat64;
  };

  public type SchedulingInterval = {
    delayNano: Nat64;
    intervalNano: Nat64;
    var iterations: Iterations;
  };

  public type Error = {
    #notFound;
    #alreadyExists;
    #notAuthorized;
  };

  public type TaskPayload = Text;

  public type TaskTimestamp = {
    taskId: Types.TaskId;
    timestamp: Nat64;
  };
}
