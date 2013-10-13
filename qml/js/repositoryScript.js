WorkerScript.onMessage = function(message) {
    // ... long-running operations and calculations are done here
    WorkerScript.sendMessage(message);
}
