const { db } = require("../config/firebase");
const { validationResult } = require("express-validator");

// CREATE ITEM
exports.createItem = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { title, description, price, category, images } = req.body;

    const newItem = {
      title,
      description,
      price: price || 0,
      category,
      images: images || [],
      sellerId: req.user.uid,
      status: "available",
      createdAt: new Date().toISOString(),
    };

    const docRef = await db.collection("items").add(newItem);

    res.status(201).json({
      message: "Item created successfully",
      id: docRef.id,
    });

  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};
// Get Item
exports.getItemById = async (req, res) => {
  try {
    const itemRef = db.collection("items").doc(req.params.id);
    const item = await itemRef.get();

    if (!item.exists) {
      return res.status(404).json({ message: "Item not found" });
    }

    res.json({
      id: item.id,
      ...item.data()
    });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
// Update Item
exports.updateItem = async (req, res) => {
  try {
    const itemRef = db.collection("items").doc(req.params.id);
    const item = await itemRef.get();

    // 1. Check if item exists
    if (!item.exists) {
      return res.status(404).json({ message: "Item not found" });
    }

    // 2. Ownership check (SECURITY)
    if (item.data().sellerId !== req.user.uid) {
      return res.status(403).json({ message: "Not authorized" });
    }

    // 3. Update allowed fields only (prevents tampering)
    const updatedData = {
      title: req.body.title || item.data().title,
      description: req.body.description || item.data().description,
      price: req.body.price || item.data().price,
      category: req.body.category || item.data().category,
      images: req.body.images || item.data().images,
      updatedAt: new Date().toISOString()
    };

    await itemRef.update(updatedData);

    res.json({
      message: "Item updated successfully",
      id: req.params.id,
      data: updatedData
    });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getAllItems = async (req, res) => {
  try {
    const snapshot = await db.collection("items")
      .where("status", "==", "available")
      .orderBy("createdAt", "desc").get();
    let items = [];
    snapshot.forEach(doc => items.push({ id: doc.id, ...doc.data() }));
    res.json(items);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.deleteItem = async (req, res) => {
  try {
    const itemRef = db.collection("items").doc(req.params.id);
    const item = await itemRef.get();
    if (!item.exists) return res.status(404).json({ message: "Item not found" });
    if (item.data().sellerId !== req.user.uid)
      return res.status(403).json({ message: "Not authorized" });
    await itemRef.delete();
    res.json({ message: "Item deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};