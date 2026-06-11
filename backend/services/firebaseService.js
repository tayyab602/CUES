const { db, auth } = require("../config/firebase");

const getUserById = async (uid) => {
  const doc = await db.collection("users").doc(uid).get();
  return doc.exists ? { id: doc.id, ...doc.data() } : null;
};

const updateItemStatus = async (itemId, status, collection = "items") => {
  await db.collection(collection).doc(itemId).update({ status });
};

module.exports = { getUserById, updateItemStatus };