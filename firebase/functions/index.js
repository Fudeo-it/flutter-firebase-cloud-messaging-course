const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotifications = functions.database.ref("messages/{chat}/{message}").onCreate(
    async (snapshot, context) => {
        const text = snapshot.child("message").val();
        const attachment = snapshot.child("attachment").val();
        const senderId = snapshot.child("sender").val();
        const chatId = context.params.chat;

        const chat = await admin.firestore().collection("chats").doc(chatId).get();
        const userRefs = chat.data().users;
        const otherRef = userRefs.find((user) => user.id !== senderId);
        const sender = (await admin.firestore().collection("users").doc(senderId).get()).data();
        const other = (await otherRef.get()).data();
        const tokens = other.tokens;

        if (tokens != null && tokens.length > 0) {
            const payload = {
                notification: {
                    title: `${sender.first_name} ${sender.last_name} posted ${attachment ? "an image" : "a message"}`,
                    body: text ? (text.length <= 100 ? text : text.substring(0, 97) + "...") : "",
                    icon: sender.avatar || "images/profile_placeholder.png",
                },
                data: {
                    type: "chat",
                    text: text,
                    attachment: String(attachment),
                    chat: String(chatId),
                    sender: String(senderId),
                    other: String(otherRef.id),
                }
            };

            const response = await admin.messaging().sendToDevice(tokens, payload);
            await cleanUpTokens(response, tokens, otherRef);
            console.log("Notifications have been sent and tokens cleaned up.");
        }
    }
);

async function cleanUpTokens(response, tokens, otherRef) {
    const tokensToDelete = [];

    response.results.forEach((result, index) => {
        const error = result.error;

        if (error) {
            console.error("Failure sending notification to", tokens[index], error);

            if (error.code === "messaging/invalid-registration-token" ||
            error.code === "messaging/registration-token-not-registered") {
                tokensToDelete.push(tokens[index]);
            }
        }
    });

    if (tokensToDelete.length > 0) {
        const goodTokens = tokens.filter(token => !tokensToDelete.includes(token));
        return await otherRef.update({
            "tokens": goodTokens
        });
    }

    return null;
}