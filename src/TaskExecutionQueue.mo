import Buffer "mo:base/Buffer";
import List "mo:base/List";
import Option "mo:base/Option";
import Heap "mo:base/Heap";
import Nat64 "mo:base/Nat64";

import Types "Types";
import TaskTimestampOrder "TaskTimestampOrder";

module {

  type TaskTimestamp = Types.TaskTimestamp;

  public class TaskExecutionQueue() {
    var heap = Heap.Heap<TaskTimestamp>(TaskTimestampOrder.compare);

    public func push(task: TaskTimestamp){
      heap.put(task);
    };

    public func add(task: TaskTimestamp){
      var result = List.nil<TaskTimestamp>();
      result := List.push<TaskTimestamp>(task, result);
    };

    public func popReady(timestamp: Nat64) : List.List<TaskTimestamp> {
      var result = List.nil<TaskTimestamp>();

      var cur : ?TaskTimestamp = heap.peekMin();
      if (Option.isNull(cur)) {
        return result;
      };

      if (Option.isNull( do ? {
          label push while (cur!.timestamp <= timestamp) {
            result := List.push<TaskTimestamp>(heap.removeMin()!, result);

            cur := heap.peekMin();
            if (Option.isNull(cur)) {
              break push
            };
          };
        }
      )){
        assert (false);
      };
      result
    };

    public func isEmpty() : Bool {
      switch (heap.peekMin()) {
        case (null) { true };
        case (?(_)) { false };
      };
    };
  };
}