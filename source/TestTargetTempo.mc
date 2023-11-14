import Toybox.Activity;
import Toybox.Lang;
import Toybox.Test;
import Toybox.Application.Properties;

//! Tests behaviour when device still reports nulls. 
//! @param logger Is a Test.Logger object
//! @return A boolean indicating success (true) or fail (false)
(:test)
function targetTempoNullTest(logger as Logger) as Boolean {
    var tt = new TargetTempoView();
    var ai = new Activity.Info();

    ai.elapsedTime = null;
    ai.elapsedDistance = null;
    ai.currentSpeed = null;
    var target = tt.compute(ai);
    if (!target.equals("6:00")) {
        logger.debug("Expected '6:00', got '" + target + "'");
        return false;
    }

    return true;
}

//! Tests behaviour when device reports zeros for elapsed values. 
//! @param logger Is a Test.Logger object
//! @return A boolean indicating success (true) or fail (false)
(:test)
function targetTempoZeroTest(logger as Logger) as Boolean {
    var tt = new TargetTempoView();
    var ai = new Activity.Info();

    ai.elapsedTime = 0;
    ai.elapsedDistance = 0.0;
    ai.currentSpeed = 0.0;
    var target = tt.compute(ai);
    if (!target.equals("6:00")) {
        logger.debug("Expected '6:00', got '" + target + "'");
        return false;
    }

    return true;
}

//! Tests behaviour when SMA window is filled. 
//! This test is dependent on the default property values in
//! targeDistance and targetTime, so make sure to revert back to default
//! after having modified persistent storage from within the simulator.
//! @param logger Is a Test.Logger object
//! @return A boolean indicating success (true) or fail (false)
(:test)
function targetTempoFillSMATest(logger as Logger) as Boolean {
    var tt = new TargetTempoView();
    var ai = new Activity.Info();
    var target = "";
 
    for (var i = 0; i < 10; i += 1) {
        ai.elapsedTime = i * 1000;
        ai.elapsedDistance = i * 60.0;
        ai.currentSpeed = 3.0;
        target = tt.compute(ai);
    }

    if (!target.equals("6:09")) {
        logger.debug("Expected '6:09', got '" + target + "'");
        return false;
    }

    return true;
}

//! Tests behaviour after SMA has handed over to EMA. 
//! This test is dependent on the default property values in
//! targeDistance and targetTime, so make sure to revert back to default
//! after having modified persistent storage from within the simulator.
//! @param logger Is a Test.Logger object
//! @return A boolean indicating success (true) or fail (false)
(:test)
function targetTempoEMATest(logger as Logger) as Boolean {
    var tt = new TargetTempoView();
    var ai = new Activity.Info();
    var target = "";
 
    for (var i = 0; i < 10; i += 1) {
        ai.elapsedTime = i * 1000;
        ai.elapsedDistance = i * 60.0;
        ai.currentSpeed = 3.0;
        tt.compute(ai);
    }

    ai.elapsedTime = 10000;
    ai.elapsedDistance = 460.0;
    target = tt.compute(ai);

    if (!target.equals("6:10")) {
        logger.debug("Expected '6:10', got '" + target + "'");
        return false;
    }

    return true;
}

//! Tests behaviour when distance is left and time is out 
//! This test is dependent on the default property values in
//! targeDistance and targetTime, so make sure to revert back to default
//! after having modified persistent storage from within the simulator.
//! @param logger Is a Test.Logger object
//! @return A boolean indicating success (true) or fail (false)
(:test)
function targetTempoDistLeftTimeEqualTest(logger as Logger) as Boolean {
    var tt = new TargetTempoView();
    var ai = new Activity.Info();

    ai.elapsedTime = 3600000;
    ai.elapsedDistance = 9970.0;
    ai.currentSpeed = 3.0;
    var target = tt.compute(ai);
    if (!target.equals("eta 60:10")) {
        logger.debug("Expected 'eta 60:10', got '" + target + "'");
        return false;
    }

    return true;
}

//! Tests behaviour when distance is done and time has passed 
//! This test is dependent on the default property values in
//! targeDistance and targetTime, so make sure to revert back to default
//! after having modified persistent storage from within the simulator.
//! @param logger Is a Test.Logger object
//! @return A boolean indicating success (true) or fail (false)
(:test)
function targetTempoDistEqualTimePassedTest(logger as Logger) as Boolean {
    var tt = new TargetTempoView();
    var ai = new Activity.Info();

    ai.elapsedTime = 3610000;
    ai.elapsedDistance = 10000.0;
    ai.currentSpeed = 3.0;
    var target = tt.compute(ai);
    if (!target.equals("fin 60:10")) {
        logger.debug("Expected 'fin 60:10', got '" + target + "'");
        return false;
    }

    return true;
}

//! Tests behaviour when internal target may blow up, i.e.
//! when there is a small fraction of distance left.
//! This also test that we can get an estimated output of 'eta 0:00'.
//! This test is dependent on the default property values in
//! targeDistance and targetTime, so make sure to revert back to default
//! after having modified persistent storage from within the simulator.
//! @param logger Is a Test.Logger object
//! @return A boolean indicating success (true) or fail (false)
(:test)
function targetTempoDistFractionLeftTest(logger as Logger) as Boolean {
    var tt = new TargetTempoView();
    var ai = new Activity.Info();

    ai.elapsedTime = 0;
    ai.elapsedDistance = 10000.0 - 0.001;
    ai.currentSpeed = 3.0;
    var target = tt.compute(ai);
    if (!target.equals("eta 0:00")) {
        logger.debug("Expected 'eta 0:00', got '" + target + "'");
        return false;
    }

    return true;
}

//! Test that we can get the limited output of 'eta 65:32'.
//! This test is dependent on the default property values in
//! targeDistance and targetTime, so make sure to revert back to default
//! after having modified persistent storage from within the simulator.
//! @param logger Is a Test.Logger object
//! @return A boolean indicating success (true) or fail (false)
(:test)
function targetTempoToHighTempoTest(logger as Logger) as Boolean {
    var tt = new TargetTempoView();
    var ai = new Activity.Info();

    ai.elapsedTime = 3599000;
    ai.elapsedDistance = 9000.0;
    ai.currentSpeed = 3.0;
    var target = tt.compute(ai);
    if (!target.equals("eta 65:32")) {
        logger.debug("Expected 'eta 65:32', got '" + target + "'");
        return false;
    }

    return true;
}

//! Tests behaviour after SMA has handed over to EMA. 
//! This test is dependent on the default property values in
//! targeDistance and targetTime, so make sure to revert back to default
//! after having modified persistent storage from within the simulator.
//! @param logger Is a Test.Logger object
//! @return A boolean indicating success (true) or fail (false)
(:test)
function targetTempoETATest(logger as Logger) as Boolean {
    Properties.setValue("displayOption", 3);
    var tt = new TargetTempoView();
    Properties.setValue("displayOption", 0);
    var ai = new Activity.Info();
    var target = "";
 
    for (var i = 0; i < 200; i += 1) {
        ai.elapsedTime = i * 1000;
        ai.elapsedDistance = i * 3.0;
        ai.currentSpeed = 3.0;
        tt.compute(ai);
    }

    ai.elapsedTime = 200000;
    ai.elapsedDistance = 600.0;
    ai.currentSpeed = 6.0;
    target = tt.compute(ai);

    // expected output given a moving window size of 120 and one item in the buffer is 6.0
    // and the rest 3.0
    if (!target.equals("eta 55:07")) {
        logger.debug("Expected 'eta 55:07', got '" + target + "'");
        return false;
    }

    for (var i = 0; i < 200; i += 1) {
        ai.elapsedTime = i * 1000 + 2000000;
        ai.elapsedDistance = i * 3.0 + 6000;
        ai.currentSpeed = 3.0;
        tt.compute(ai);
    }

    ai.elapsedTime = 2200000;
    ai.elapsedDistance = 6600.0;
    ai.currentSpeed = 6.0;
    target = tt.compute(ai);

    // expected output given a moving window size of 60 and one item in the buffer is 6.0
    // and the rest 3.0
    if (!target.equals("eta 55:14")) {
        logger.debug("Expected 'eta 55:14', got '" + target + "'");
        return false;
    }

    for (var i = 0; i < 100; i += 1) {
        ai.elapsedTime = i * 1000 + 2833333;
        ai.elapsedDistance = i * 3.0 + 8500;
        ai.currentSpeed = 3.0;
        tt.compute(ai);
    }

    ai.elapsedTime = 2933333;
    ai.elapsedDistance = 8800.0;
    ai.currentSpeed = 6.0;
    target = tt.compute(ai);

    // expected output given a moving window size of 10 and one item in the buffer is 6.0
    // and the rest 3.0
    if (!target.equals("eta 54:56")) {
        logger.debug("Expected 'eta 54:56', got '" + target + "'");
        return false;
    }

    return true;
}