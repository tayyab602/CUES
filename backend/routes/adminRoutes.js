const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const adminMiddleware = require("../middleware/adminMiddleware");

const {
  getAllUsers,
  deleteAnyItem,
  getStats,
  getReports
} = require("../controllers/adminController");

// ALL ADMIN ROUTES ARE PROTECTED
router.use(authMiddleware);
router.use(adminMiddleware);

// USERS
router.get("/users", getAllUsers);

// DELETE ANYTHING
router.delete("/delete", deleteAnyItem);

// STATS
router.get("/stats", getStats);

// REPORTS
router.get("/reports", getReports);

module.exports = router;