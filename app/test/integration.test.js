// tests/integration.test.js

const request = require("supertest");
const app = require("../app");

describe("GET /", () => {
  test("Should return status 200", async () => {
    const response = await request(app).get("/");
    expect(response.statusCode).toBe(200);
  });
});