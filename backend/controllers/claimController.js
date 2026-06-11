const { db } = require("../config/firebase");

exports.createClaim = async (req, res) => {
  try {
    const { itemId, type } = req.body;
    const claim = {
      itemId,
      requesterId: req.user.uid,
      type,
      status: "pending",
      createdAt: new Date().toISOString()
    };
    const doc = await db.collection("claims").add(claim);
    res.status(201).json({ message: "Claim request submitted", id: doc.id });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.approveClaim = async (req, res) => {
  try {
    const claimRef = db.collection("claims").doc(req.params.id);
    const claim = await claimRef.get();
    if (!claim.exists) return res.status(404).json({ message: "Claim not found" });
    await claimRef.update({ status: "approved" });
    res.json({ message: "Claim approved" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.rejectClaim = async (req, res) => {
  try {
    const claimRef = db.collection("claims").doc(req.params.id);
    const claim = await claimRef.get();
    if (!claim.exists) return res.status(404).json({ message: "Claim not found" });
    await claimRef.update({ status: "rejected" });
    res.json({ message: "Claim rejected" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getAllClaims = async (req, res) => {
  try {
    const snapshot = await db.collection("claims")
      .orderBy("createdAt", "desc").get();
    let claims = [];
    snapshot.forEach(doc => claims.push({ id: doc.id, ...doc.data() }));
    res.json(claims);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};