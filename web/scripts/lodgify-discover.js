const apiKey = process.env.LODGIFY_API_KEY;
const baseUrl = process.env.LODGIFY_API_BASE ?? "https://api.lodgify.com";
const propertyId = process.env.LODGIFY_PROPERTY_ID;

if (!apiKey) {
  console.error("Missing LODGIFY_API_KEY in the environment.");
  process.exit(1);
}

async function request(path) {
  const response = await fetch(`${baseUrl}${path}`, {
    headers: {
      accept: "application/json",
      "X-ApiKey": apiKey,
    },
  });

  const text = await response.text();
  if (!response.ok) {
    console.error(`Request failed (${response.status}): ${text.slice(0, 500)}`);
    process.exit(1);
  }

  try {
    return JSON.parse(text);
  } catch {
    return text;
  }
}

async function run() {
  const properties = await request("/v2/properties");
  console.log("Properties:");
  console.log(JSON.stringify(properties, null, 2));

  if (propertyId) {
    const rooms = await request(`/v2/properties/${propertyId}/rooms`);
    console.log("Rooms:");
    console.log(JSON.stringify(rooms, null, 2));
  } else {
    console.log("Set LODGIFY_PROPERTY_ID to fetch rooms for a property.");
  }
}

run().catch((error) => {
  console.error("Unexpected error:", error);
  process.exit(1);
});
