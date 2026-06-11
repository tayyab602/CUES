const { db } = require("../config/firebase");
// get all users
exports.getAllUsers = async (req, res) => {
  try {
    const snapshot = await db.collection("users").get();

    let users = [];

    snapshot.forEach(doc => {
      users.push({ id: doc.id, ...doc.data() });
    });

    res.json(users);

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
// delete any item
exports.deleteAnyItem = async (req, res) => {
  try {
    const { collection, id } = req.body;
    // collection = "items" | "lostItems" | "foundItems"

    if (!collection || !id) {
      return res.status(400).json({ message: "Invalid request" });
    }

    const docRef = db.collection(collection).doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({ message: "Item not found" });
    }

    await docRef.delete();

    res.json({ message: "Deleted successfully" });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
// analytics
exports.getStats = async (req, res) => {
  try {
    const users = await db.collection("users").get();
    const items = await db.collection("items").get();
    const lost = await db.collection("lostItems").get();
    const found = await db.collection("foundItems").get();
    const chats = await db.collection("chats").get();

    res.json({
      totalUsers: users.size,
      totalItems: items.size,
      totalLostItems: lost.size,
      totalFoundItems: found.size,
      totalChats: chats.size
    });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
// reports
exports.getReports = async (req, res) => {
  try {
    const snapshot = await db.collection("reports").get();

    let reports = [];

    snapshot.forEach(doc => {
      reports.push({ id: doc.id, ...doc.data() });
    });

    res.json(reports);

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};