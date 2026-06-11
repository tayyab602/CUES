// found item
exports.createFoundItem = async (req, res) => {
  try {
    const { title, description, location, images, category } = req.body;

    const foundItem = {
      title,
      description,
      location,
      category,
      images: images || [],
      finderId: req.user.uid,
      status: "unclaimed",
      createdAt: new Date().toISOString()
    };

    const doc = await db.collection("foundItems").add(foundItem);

    res.status(201).json({
      message: "Found item reported successfully",
      id: doc.id
    });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
// get all found
exports.getAllFoundItems = async (req, res) => {
  try {
    const snapshot = await db.collection("foundItems")
      .where("status", "==", "unclaimed")
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
// smart matching
exports.matchItems = async (req, res) => {
  try {
    const keyword = req.query.keyword?.toLowerCase();

    const snapshot = await db.collection("foundItems")
      .where("status", "==", "unclaimed")
      .get();

    let matches = [];

    snapshot.forEach(doc => {
      const data = doc.data();

      if (
        data.title.toLowerCase().includes(keyword) ||
        data.category.toLowerCase().includes(keyword)
      ) {
        matches.push({ id: doc.id, ...data });
      }
    });

    res.json(matches);

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};