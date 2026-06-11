const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");
const { createClaim, approveClaim, rejectClaim, getAllClaims } = require("../controllers/claimController");

router.post("/request", authMiddleware, createClaim);
router.put("/approve/:id", authMiddleware, approveClaim);
router.put("/reject/:id", authMiddleware, rejectClaim);
router.get("/all", authMiddleware, getAllClaims);

module.exports = router;