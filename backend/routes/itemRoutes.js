const express = require("express");
const router = express.Router();

// Middleware
const authMiddleware = require("../middleware/authMiddleware");

// Validators
const { createItemValidator } = require("../validators/itemValidator");

// Controller
const {
  createItem,
  getAllItems,
  deleteItem,
  updateItem,
  getItemById
} = require("../controllers/itemController");

// Validation error handler (kept inside routes for simplicity & clarity)
const { validationResult } = require("express-validator");

const validateRequest = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      message: "Validation error",
      errors: errors.array()
    });
  }
  next();
};
//# 🛒 ITEM ROUTES

// Create new item (protected)
router.post(
  "/create",
  authMiddleware,
  createItemValidator,
  validateRequest,
  createItem
);

// Get all available items (public)
router.get("/all", getAllItems);

// Get single item by ID (public)
router.get("/:id", getItemById);

// Update item (only owner)
router.put(
  "/update/:id",
  authMiddleware,
  createItemValidator, // optional reuse or create update validator later
  validateRequest,
  updateItem
);

// Delete item (only owner)
router.delete(
  "/delete/:id",
  authMiddleware,
  deleteItem
);

module.exports = router;