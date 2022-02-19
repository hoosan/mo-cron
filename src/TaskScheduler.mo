import Heap "mo:base/Heap";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Nat64 "mo:base/Nat64";
import Result "mo:base/Result";
import Option "mo:base/Option";

import Types "Types";
import ScheduledTask "ScheduledTask";
import TaskExecutionQueue "TaskExecutionQueue";

module {

  type TaskId = Types.TaskId;
  type SchedulingInterval = Types.SchedulingInterval;
  type Iterations = Types.Iterations;
  type Error = Types.Error;
  type TaskPayload = Types.TaskPayload;
  type TaskTimestamp = Types.TaskTimestamp;
  type ScheduledTask = ScheduledTask.ScheduledTask;

  public class TaskScheduler(){

    var tasks = HashMap.HashMap<TaskId, ScheduledTask>(1, Nat64.equal, func(x){Hash.hash(Nat64.toNat(x))});

    var task_id_counter: TaskId = 0;
    var queue = TaskExecutionQueue.TaskExecutionQueue();

    public func enqueue(
      payload: TaskPayload,
      schedulingInterval: SchedulingInterval,
      timestamp: Nat64,
    ) : Result.Result<TaskId,Error> {
        let id = generate_task_id();
        let task = ScheduledTask.ScheduledTask(
          id, payload, timestamp, null, schedulingInterval
        );
        switch(task.schedulingInterval().iterations) {
          case (#Exact(times)) {
            if (times > 0) {
              queue.push({ taskId = id; timestamp = timestamp + task.schedulingInterval().delayNano});
            };
          };
          case (#Infinite) {
            queue.push({ taskId = id; timestamp = timestamp + task.schedulingInterval().delayNano});
          };
        };

        tasks.put(id, task);
        
        #ok(id)
    };

    public func iterate(timestamp: Nat64) : List.List<ScheduledTask> {
      var currentTasks = List.nil<ScheduledTask>();
      
      let taskIdList = List.map<TaskTimestamp, TaskId>(queue.popReady(timestamp), func(t){ t.taskId });
    
      List.iterate<TaskId>(taskIdList, func(taskId){
        var shouldRemove = false;

        let _task = tasks.get(taskId);
        switch _task {
          case null {};
          case (?(task)) {
            switch(task.schedulingInterval().iterations){
              case(#Infinite){
                let newRescheduledAt = calcNewScheduledAt(task);
                task.setRescheduledAt(newRescheduledAt);
                if (Option.isNull( do ? {
                  queue.push({ taskId = taskId; timestamp = newRescheduledAt! + task.schedulingInterval().intervalNano});
                })) { 
                  assert(false);
                };
              };
              case(#Exact(timesLeft)){
                if (timesLeft > 1){
                  let newRescheduledAt = calcNewScheduledAt(task);
                  task.setRescheduledAt(newRescheduledAt);
                  if (Option.isNull( do ? {
                    queue.push({ taskId = taskId; timestamp = newRescheduledAt! + task.schedulingInterval().intervalNano});
                  })) { 
                    assert(false);
                  };
                  task.schedulingInterval().iterations := #Exact(timesLeft - 1);
                } else {
                  shouldRemove := true;
                }
              };
            };
            currentTasks := List.push<ScheduledTask>(task, currentTasks);
          };
        };
        if (shouldRemove) {
          tasks.delete(taskId);
        };
      });

      currentTasks
    };

    public func dequeue(taskId: TaskId): ?ScheduledTask {
      tasks.remove(taskId)
    };

    public func isEmpty(): Bool {
      queue.isEmpty()
    };

    public func getTaskById(taskId: TaskId) : [ScheduledTask] {
      Iter.toArray(tasks.vals())
    };

    private func generate_task_id() : TaskId {
      let res = task_id_counter;
      task_id_counter += 1;
      res
    };

    private func calcNewScheduledAt(task: ScheduledTask.ScheduledTask): ?Nat64 {
      do ? {
        let newRescheduledAt = if (task.delayPassed()) {
          if (Option.isSome(task.rescheduledAt())) {
            task.rescheduledAt()! + task.schedulingInterval().intervalNano
          } else {
            task.scheduledAt() + task.schedulingInterval().intervalNano
          }
        } else {
          task.setDelayPassed(true);

          if (Option.isSome(task.rescheduledAt())) {
            task.rescheduledAt()! + task.schedulingInterval().delayNano
          } else {
            task.scheduledAt() + task.schedulingInterval().delayNano
          }
        };
        newRescheduledAt
      }
    };
  };
}
