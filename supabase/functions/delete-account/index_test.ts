// Runs the real request handler with HTTP replaced; no live accounts are used.
let handler: (req: Request) => Promise<Response>;
const originalServe = Deno.serve;
const originalFetch = globalThis.fetch;
Deno.env.set("SUPABASE_URL", "https://account-test.invalid");
Deno.env.set("SUPABASE_ANON_KEY", "test-key");
Deno.env.set("SUPABASE_SERVICE_ROLE_KEY", "test-service-key");
Deno.serve = ((callback: typeof handler) => {
  handler = callback;
  return {};
}) as typeof Deno.serve;
await import("./index.ts");
Deno.serve = originalServe;

Deno.test("deletion requires the confirmed identity before any admin request", async () => {
  const adminRequests: string[] = [];
  globalThis.fetch = async (input) => {
    const url = String(input instanceof Request ? input.url : input);
    if (url.endsWith("/auth/v1/user")) {
      return Response.json({
        id: "22222222-2222-4222-8222-222222222222",
        aud: "authenticated",
        app_metadata: {},
        user_metadata: {},
        created_at: "",
      });
    }
    adminRequests.push(url);
    if (url.includes("/rest/v1/journals")) {
      return Response.json([{ id: "journal-b" }]);
    }
    if (
      url.endsWith("/auth/v1/admin/users/22222222-2222-4222-8222-222222222222")
    ) return Response.json({});
    throw new Error(`Unexpected HTTP request: ${url}`);
  };
  try {
    for (
      const body of [undefined, {}, {
        expectedUserId: "11111111-1111-4111-8111-111111111111",
      }]
    ) {
      const response = await handler(
        new Request("https://account-test.invalid/delete-account", {
          method: "POST",
          headers: { Authorization: "Bearer test-token" },
          body: body === undefined ? undefined : JSON.stringify(body),
        }),
      );
      if (response.status < 400 || adminRequests.length) {
        throw new Error("Unsafe deletion accepted");
      }
    }
    const response = await handler(
      new Request("https://account-test.invalid/delete-account", {
        method: "POST",
        headers: { Authorization: "Bearer test-token" },
        body: JSON.stringify({
          expectedUserId: "22222222-2222-4222-8222-222222222222",
        }),
      }),
    );
    const body = await response.json();
    if (
      response.status !== 200 || body.deletedJournalIds[0] !== "journal-b" ||
      adminRequests.filter((url) =>
          url.endsWith(
            "/auth/v1/admin/users/22222222-2222-4222-8222-222222222222",
          )
        ).length !== 1
    ) {
      throw new Error(
        "Matching identity did not delete exactly the intended user",
      );
    }
  } finally {
    globalThis.fetch = originalFetch;
  }
});
