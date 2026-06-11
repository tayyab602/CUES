const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");

const {
  createLostItem,
  getAllLostItems,
  createFoundItem,
  getAllFoundItems,
  matchItems
} = require("../controllers/lostController");

// LOST
router.post("/lost/create", authMiddleware, createLostItem);
router.get("/lost/all", getAllLostItems);

// FOUND
router.post("/found/create", authMiddleware, createFoundItem);
router.get("/found/all", getAllFoundItems);

// MATCHING
router.get("/match", matchItems);

module.exports = router;