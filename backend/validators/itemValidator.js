const { body } = require("express-validator");

const createItemValidator = [
  body("title").isString().isLength({ min: 3, max: 100 }),
  body("description").isString().isLength({ min: 5, max: 500 }),
  body("price").isNumeric().optional(),
  body("category").isString().notEmpty(),
];

module.exports = { createItemValidator };