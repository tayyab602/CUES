const { db } = require("../config/firebase");

// CREATE LOST ITEM
exports.createLostItem = async (req, res) => {
  try {
    const { title, description, location, images, category } = req.body;

    const lostItem = {
      title,
      description,
      location,
      category,
      images: images || [],
      userId: req.user.uid,
      status: "active",
      createdAt: new Date().toISOString()
    };

    const doc = await db.collection("lostItems").add(lostItem);

    res.status(201).json({
      message: "Lost item reported successfully",
      id: doc.id
    });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
// get all item
exports.getAllLostItems = async (req, res) => {
  try {
    const snapshot = await db.collection("lostItems")
      .where("status", "==", "active")
      .orderBy("createdAt", "desc")
      .get();

    let items = [];

    snapshot.forEach(doc => {
      items.push({ id: doc.id, ...doc.data() });
    });

    res.json(items);

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.createFoundItem = async (req, res) => {
  try {
    const { title, description, location, images, category } = req.body;
    const foundItem = {
      title, description, location, category,
      images: images || [],
      finderId: req.user.uid,
      status: "unclaimed",
      createdAt: new Date().toISOString()
    };
    const doc = await db.collection("foundItems").add(foundItem);
    res.status(201).json({ message: "Found item reported successfully", id: doc.id });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getAllFoundItems = async (req, res) => {
  try {
    const snapshot = await db.collection("foundItems")
      .where("status", "==", "unclaimed")
      .orderBy("createdAt", "desc").get();
    let items = [];
    snapshot.forEach(doc => items.push({ id: doc.id, ...doc.data() }));
    res.json(items);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.matchItems = async (req, res) => {
  try {
    const { keyword, category } = req.query;
    const snapshot = await db.collection("foundItems")
      .where("status", "==", "unclaimed").get();
    let matches = [];
    snapshot.forEach(doc => {
      const data = doc.data();
      const titleMatch = data.title?.toLowerCase().includes(keyword?.toLowerCase());
      const categoryMatch = category ? data.category === category : true;
      if (titleMatch && categoryMatch) matches.push({ id: doc.id, ...data });
    });
    res.json(matches);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};