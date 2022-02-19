import Debug "mo:base/Debug";
import Result "mo:base/Result";
import Option "mo:base/Option";
import Nat64 "mo:base/Nat64";
import List "mo:base/List";

import TaskScheduler "../src/TaskScheduler";
import ScheduledTask "../src/ScheduledTask";

type ScheduledTask = ScheduledTask.ScheduledTask;

/// Main flow works fine
do {
  var scheduler = TaskScheduler.TaskScheduler();

  if (Option.isNull( do ? {

    let taskId1 = Result.toOption(scheduler.enqueue(
      "a",
      {
        delayNano = 10;
        intervalNano = 10;
        var iterations = #Exact(1);
      },
      0
    ))!;

    let taskId2 = Result.toOption(scheduler.enqueue(
      "a",
      {
        delayNano = 10;
        intervalNano = 10;
        var iterations = #Infinite;
      },
      0
    ))!;

    let taskId3 = Result.toOption(scheduler.enqueue(
      "a",
      {
        delayNano = 20;
        intervalNano = 20;
        var iterations = #Exact(2);
      },
      0
    ))!;

    Debug.print("Scheduler should not be empty");
    assert(scheduler.isEmpty() == false);

    let tasksAtTimestamp5 = scheduler.iterate(5);
    Debug.print("There should not be any tasks at timestamp 5");
    assert(List.isNil(tasksAtTimestamp5));

    let tasksAtTimestamp10 = scheduler.iterate(10);
    Debug.print("There should be two tasks at timestamp 10");
    assert(List.size(tasksAtTimestamp10) == 2);

    Debug.print("Should contain task 1");
    assert(List.some<ScheduledTask>(tasksAtTimestamp10, func (t) { t.id() == taskId1 }));

    Debug.print("Should contain task 2");
    assert(List.some<ScheduledTask>(tasksAtTimestamp10, func (t) { t.id() == taskId2 }));
   
    let tasksAtTimestamp15 = scheduler.iterate(15);
    Debug.print("There should not be any tasks at timestamp 15");
    assert(List.isNil(tasksAtTimestamp15));

    let tasksAtTimestamp20 = scheduler.iterate(20);
    Debug.print("There should be two tasks at timestamp 20");
    assert(List.size(tasksAtTimestamp20) == 2);

    Debug.print("Should contain task 2");
    assert(List.some<ScheduledTask>(tasksAtTimestamp20, func (t) { t.id() == taskId2 }));
   
    Debug.print("Should contain task 3");
    assert(List.some<ScheduledTask>(tasksAtTimestamp20, func (t) { t.id() == taskId3 }));
   
    let tasksAtTimestamp30 = scheduler.iterate(30);
    Debug.print("There should be single task at timestamp 30");
    assert(List.size(tasksAtTimestamp30) == 1);
   
    Debug.print("Should contain task 2");
    assert(List.some<ScheduledTask>(tasksAtTimestamp30, func (t) { t.id() == taskId2 }));
   
    let tasksAtTimestamp40 = scheduler.iterate(40);
    Debug.print("There should be two task at timestamp 40");
    assert(List.size(tasksAtTimestamp40) == 2);

    Debug.print("Should contain task 2");
    assert(List.some<ScheduledTask>(tasksAtTimestamp40, func (t) { t.id() == taskId2 }));
   
    Debug.print("Should contain task 3");
    assert(List.some<ScheduledTask>(tasksAtTimestamp40, func (t) { t.id() == taskId3 }));
   
    let tasksAtTimestamp60 = scheduler.iterate(60);
    Debug.print("There should be single task at timestamp 60");
    assert(List.size(tasksAtTimestamp60) == 1);

    Debug.print("Should contain task 2");
    assert(List.some<ScheduledTask>(tasksAtTimestamp60, func (t) { t.id() == taskId2 }));
   
    let dequeuedTask = scheduler.dequeue(taskId2)!;

    let tasksAtTimestamp80 = scheduler.iterate(80);
    Debug.print("There should not be any tasks at timestamp 80");
    assert(List.size(tasksAtTimestamp80) == 0);

  })) {
    assert (false);
  };
};

/// Delay works fine
do {
  var scheduler = TaskScheduler.TaskScheduler();

  if (Option.isNull( do ? {

    let taskId1 = Result.toOption(scheduler.enqueue(
      "a",
      {
        delayNano = 10;
        intervalNano = 20;
        var iterations = #Infinite;
      },
      0
    ))!;

    let tasksAtTimestamp5 = scheduler.iterate(5);
    Debug.print("There should not be any tasks at timestamp 5");
    assert(List.size(tasksAtTimestamp5) == 0);

    let tasksAtTimestamp10 = scheduler.iterate(10);
    Debug.print("There should be a task that was triggered by a delay at this timestamp (10)");
    assert(List.size(tasksAtTimestamp10) == 1);

    let tasksAtTimestamp20 = scheduler.iterate(20);
    Debug.print("There shouldn't be any task at this timestamp (20)");
    assert(List.size(tasksAtTimestamp20) == 0);

    let tasksAtTimestamp30 = scheduler.iterate(30);
    Debug.print("There should be a task that was triggered by an interval at this timestamp (30)");
    assert(List.size(tasksAtTimestamp30) == 1);

    let tasksAtTimestamp50 = scheduler.iterate(50);
    Debug.print("There should be a task that was triggered by an interval at this timestamp (50)");
    assert(List.size(tasksAtTimestamp50) == 1);

  })) {
    assert (false);
  };
};


