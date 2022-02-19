import Order "mo:base/Order";
import Types "Types";

module {
  
  type TaskTimestamp = Types.TaskTimestamp;

  public func compare(t1: TaskTimestamp, t2: TaskTimestamp) : Order.Order {
    if (t1.timestamp < t2.timestamp) { #less }
    else if (t1.timestamp == t2.timestamp) { #equal }
    else { #greater }
  };
}