db.getCollection("users").insert({"_id":"nM6vXyDLGGzSPsLNy","createdAt":new Date(1584022531608),"services":{"password":{"bcrypt":"$2b$10$fXL9kVkWeKA7TbP2skwau.Xu3V52q1x/YPfZQ4oYjHhCRPdXwZOQ6"},"email":{"verificationTokens":[{"token":"YadCnp4E2o8lD8ZEyzn320qjoW9QEIGSU1jsaR2840J","address":"admin@example.com","when":new Date(1584022531675)}]},"resume":{"loginTokens":[]}},"emails":[{"address":"admin@example.com","verified":false}],"type":"user","status":"offline","active":true,"_updatedAt":new Date(1589468245023),"roles":["admin"],"name":"Admin","lastLogin":new Date(1589465335818),"statusConnection":"offline","username":"admin","utcOffset":NumberInt(1),"statusDefault":"online","statusText":"Lunch"});  //Password = "password"
db.getCollection("users").insert({
  _id: "pigeon.cat",
  createdAt: new Date(1584022383007),
  avatarOrigin: "local",
  name: "Pigeon.Cat",
  username: "pigeon.cat",
  status: "online",
  statusDefault: "online",
  utcOffset: NumberInt(0),
  active: true,
  type: "bot",
  _updatedAt: new Date(1584022383316),
  roles: ["bot"],
});
