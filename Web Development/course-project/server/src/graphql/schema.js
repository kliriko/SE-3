const {
  GraphQLObjectType,
  GraphQLSchema,
  GraphQLString,
  GraphQLInt,
  GraphQLBoolean,
  GraphQLList,
  GraphQLNonNull,
  GraphQLID,
} = require("graphql");
const characterService = require("../services/characterService");

const CharacterType = new GraphQLObjectType({
  name: "Character",
  fields: {
    id: { type: GraphQLID },
    name: { type: GraphQLString },
    className: { type: GraphQLString },
    race: { type: GraphQLString },
    level: { type: GraphQLInt },
    alignment: { type: GraphQLString },
    str: { type: GraphQLInt },
    dex: { type: GraphQLInt },
    con: { type: GraphQLInt },
    int: { type: GraphQLInt },
    wis: { type: GraphQLInt },
    cha: { type: GraphQLInt },
    ac: { type: GraphQLInt },
    ms: { type: GraphQLInt },
    hp: { type: GraphQLInt },
    ownerId: { type: GraphQLInt },
    ownerName: { type: GraphQLString },
    isActive: { type: GraphQLBoolean },
    createdAt: { type: GraphQLString },
    updatedAt: { type: GraphQLString },
  },
});

const UserType = new GraphQLObjectType({
  name: "User",
  fields: {
    id: { type: GraphQLInt },
    email: { type: GraphQLString },
    firstName: { type: GraphQLString },
    lastName: { type: GraphQLString },
    role: { type: GraphQLString },
    isVerified: { type: GraphQLBoolean },
  },
});

function ensureUser(context) {
  if (!context.req.session.user) {
    throw new Error("Unauthorized");
  }
  return context.req.session.user;
}

const QueryType = new GraphQLObjectType({
  name: "Query",
  fields: {
    me: {
      type: UserType,
      resolve: (_, __, context) => context.req.session.user || null,
    },
    character: {
      type: CharacterType,
      args: {
        id: { type: new GraphQLNonNull(GraphQLID) },
      },
      resolve: (_, args, context) => {
        const user = ensureUser(context);
        return characterService.getCharacter(user, Number(args.id));
      },
    },
    characters: {
      type: new GraphQLList(CharacterType),
      args: {
        q: { type: GraphQLString },
        className: { type: GraphQLString },
        isActive: { type: GraphQLBoolean },
      },
      resolve: (_, args, context) => {
        const user = ensureUser(context);
        return characterService.listCharacters(user, {
          q: args.q || "",
          className: args.className || "",
          isActive: typeof args.isActive === "boolean" ? (args.isActive ? 1 : 0) : undefined,
        });
      },
    },
  },
});

const MutationType = new GraphQLObjectType({
  name: "Mutation",
  fields: {
    createCharacter: {
      type: CharacterType,
      args: {
        name: { type: new GraphQLNonNull(GraphQLString) },
        className: { type: new GraphQLNonNull(GraphQLString) },
        race: { type: new GraphQLNonNull(GraphQLString) },
        level: { type: new GraphQLNonNull(GraphQLInt) },
        alignment: { type: GraphQLString },
        str: { type: new GraphQLNonNull(GraphQLInt) },
        dex: { type: new GraphQLNonNull(GraphQLInt) },
        con: { type: new GraphQLNonNull(GraphQLInt) },
        int: { type: new GraphQLNonNull(GraphQLInt) },
        wis: { type: new GraphQLNonNull(GraphQLInt) },
        cha: { type: new GraphQLNonNull(GraphQLInt) },
        ac: { type: new GraphQLNonNull(GraphQLInt) },
        ms: { type: new GraphQLNonNull(GraphQLInt) },
        hp: { type: new GraphQLNonNull(GraphQLInt) },
        ownerId: { type: GraphQLInt },
        isActive: { type: GraphQLBoolean },
      },
      resolve: (_, args, context) => {
        const user = ensureUser(context);
        return characterService.createCharacter(user, args);
      },
    },
    updateCharacter: {
      type: CharacterType,
      args: {
        id: { type: new GraphQLNonNull(GraphQLID) },
        name: { type: new GraphQLNonNull(GraphQLString) },
        className: { type: new GraphQLNonNull(GraphQLString) },
        race: { type: new GraphQLNonNull(GraphQLString) },
        level: { type: new GraphQLNonNull(GraphQLInt) },
        alignment: { type: GraphQLString },
        str: { type: new GraphQLNonNull(GraphQLInt) },
        dex: { type: new GraphQLNonNull(GraphQLInt) },
        con: { type: new GraphQLNonNull(GraphQLInt) },
        int: { type: new GraphQLNonNull(GraphQLInt) },
        wis: { type: new GraphQLNonNull(GraphQLInt) },
        cha: { type: new GraphQLNonNull(GraphQLInt) },
        ac: { type: new GraphQLNonNull(GraphQLInt) },
        ms: { type: new GraphQLNonNull(GraphQLInt) },
        hp: { type: new GraphQLNonNull(GraphQLInt) },
        isActive: { type: GraphQLBoolean },
      },
      resolve: (_, args, context) => {
        const user = ensureUser(context);
        return characterService.updateCharacter(user, Number(args.id), args);
      },
    },
    toggleCharacterActive: {
      type: CharacterType,
      args: {
        id: { type: new GraphQLNonNull(GraphQLID) },
        isActive: { type: new GraphQLNonNull(GraphQLBoolean) },
      },
      resolve: (_, args, context) => {
        const user = ensureUser(context);
        return characterService.setCharacterActive(user, Number(args.id), args.isActive);
      },
    },
    deleteCharacter: {
      type: GraphQLString,
      args: {
        id: { type: new GraphQLNonNull(GraphQLID) },
      },
      resolve: (_, args, context) => {
        const user = ensureUser(context);
        characterService.removeCharacter(user, Number(args.id));
        return "Deleted";
      },
    },
  },
});

module.exports = new GraphQLSchema({
  query: QueryType,
  mutation: MutationType,
});
