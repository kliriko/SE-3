const listeners = new Set();

function subscribe(res) {
  listeners.add(res);
}

function unsubscribe(res) {
  listeners.delete(res);
}

function emitCharacterUpdated(payload) {
  const serialized = `data: ${JSON.stringify(payload)}\n\n`;
  for (const res of listeners) {
    res.write(serialized);
  }
}

module.exports = {
  subscribe,
  unsubscribe,
  emitCharacterUpdated,
};
