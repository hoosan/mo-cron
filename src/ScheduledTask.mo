import Nat64 "mo:base/Nat64";
import Option "mo:base/Option";
import Result "mo:base/Result";

import Types "Types";

module {

  type Error = Types.Error;
  type SchedulingInterval = Types.SchedulingInterval;
  type Task = Types.Task;
  type TaskId = Types.TaskId;
  type TaskPayload = Types.TaskPayload;

  public class ScheduledTask(
    idInit: TaskId,
    payloadInit: TaskPayload,
    scheduledAtInit: Nat64,
    rescheduledAtInit: ?Nat64,
    schedulingIntervalInit: SchedulingInterval
  ) {

    var _id : TaskId = idInit;
    var _scheduledAt : Nat64 = scheduledAtInit;
    var _rescheduledAt : ?Nat64 = rescheduledAtInit;
    var _schedulingInterval : SchedulingInterval = schedulingIntervalInit;

    var _payload: Task = {
      data = payloadInit;
    };
    var _delayPassed: Bool = false;

    public func payload() : Text {
      _payload.data
    };

    public func id(): TaskId {
      _id
    };

    public func scheduledAt(): Nat64 {
      _scheduledAt
    };

    public func rescheduledAt() : ?Nat64 {
      _rescheduledAt
    };

    public func setRescheduledAt(x: ?Nat64) {
      _rescheduledAt := x;
    };

    public func schedulingInterval() : SchedulingInterval {
      _schedulingInterval
    };

    public func delayPassed() : Bool {
      _delayPassed
    };

    public func setDelayPassed(x: Bool) {
      _delayPassed := x;
    };

  }
}
