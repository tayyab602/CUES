const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");

const {
  createOrGetChat,
  getUserChats,
  sendMessage,
  getMessages
} = require("../controllers/chatController");

// create or open chat
router.post("/create", authMiddleware, createOrGetChat);

// get all user chats
router.get("/my", authMiddleware, getUserChats);

// send message
router.post("/message", authMiddleware, sendMessage);

// get messages of chat
router.get("/message/:chatId", authMiddleware, getMessages);

module.exports = router;