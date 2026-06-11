const { db } = require("../config/firebase");
//CREATE OR GET CHAT
exports.createOrGetChat = async (req, res) => {
  try {
    const { receiverId, itemId } = req.body;

    const senderId = req.user.uid;

    // check if chat already exists
    const chatSnapshot = await db.collection("chats")
      .where("participants", "array-contains", senderId)
      .get();

    let existingChat = null;

    chatSnapshot.forEach(doc => {
      const data = doc.data();

      if (data.participants.includes(receiverId)) {
        existingChat = { id: doc.id, ...data };
      }
    });

    if (existingChat) {
      return res.json(existingChat);
    }

    // create new chat
    const newChat = {
      participants: [senderId, receiverId],
      itemId: itemId || null,
      lastMessage: "",
      updatedAt: new Date().toISOString()
    };

    const doc = await db.collection("chats").add(newChat);

    res.status(201).json({
      id: doc.id,
      ...newChat
    });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
//GET USER CHATS
exports.getUserChats = async (req, res) => {
  try {
    const userId = req.user.uid;

    const snapshot = await db.collection("chats")
      .where("participants", "array-contains", userId)
      .orderBy("updatedAt", "desc")
      .get();

    let chats = [];

    snapshot.forEach(doc => {
      chats.push({ id: doc.id, ...doc.data() });
    });

    res.json(chats);

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
// send messages
exports.sendMessage = async (req, res) => {
  try {
    const { chatId, text } = req.body;

    const message = {
      chatId,
      senderId: req.user.uid,
      text,
      createdAt: new Date().toISOString()
    };

    await db.collection("messages").add(message);

    // update chat last message
    await db.collection("chats").doc(chatId).update({
      lastMessage: text,
      updatedAt: new Date().toISOString()
    });

    res.status(201).json({ message: "Message sent" });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
// get messages
exports.getMessages = async (req, res) => {
  try {
    const { chatId } = req.params;

    const snapshot = await db.collection("messages")
      .where("chatId", "==", chatId)
      .orderBy("createdAt", "asc")
      .get();

    let messages = [];

    snapshot.forEach(doc => {
      messages.push({ id: doc.id, ...doc.data() });
    });

    res.json(messages);

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};