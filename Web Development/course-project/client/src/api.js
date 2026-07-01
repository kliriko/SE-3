const BASE_URL = "http://localhost:4000";

async function parseResponse(response) {
  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.message || "Request failed");
  }
  return data;
}

export async function restRequest(path, options = {}) {
  const response = await fetch(`${BASE_URL}${path}`, {
    credentials: "include",
    headers: {
      "Content-Type": "application/json",
      ...(options.headers || {}),
    },
    ...options,
  });

  return parseResponse(response);
}

export async function graphqlRequest(query, variables = {}) {
  const response = await fetch(`${BASE_URL}/api/graphql`, {
    method: "POST",
    credentials: "include",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ query, variables }),
  });

  const body = await parseResponse(response);
  if (body.errors?.length) {
    throw new Error(body.errors[0].message || "GraphQL error");
  }

  return body.data;
}

export function createCharactersEventSource() {
  return new EventSource(`${BASE_URL}/api/events/characters`, { withCredentials: true });
}
