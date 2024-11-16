/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");


const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.verificarResposta = functions.https.onCall(async (data, context) => {
  const { desafioId, faseId, perguntaId, respostaUsuario } = data;

  try {
    const desafioDoc = await admin.firestore().collection("desafios").doc(desafioId).get();

    if (!desafioDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Desafio não encontrado.");
    }

    const desafioData = desafioDoc.data();
    const fase = desafioData.desafios.find((f) => f.fase === faseId);
    if (!fase) {
      throw new functions.https.HttpsError("not-found", "Fase não encontrada.");
    }

    const pergunta = fase.perguntas.find((p) => p.id === perguntaId);
    if (!pergunta) {
      throw new functions.https.HttpsError("not-found", "Pergunta não encontrada.");
    }

    const respostaCorreta = pergunta.resposta;
    return {
      resultado: respostaUsuario.trim().toLowerCase() === respostaCorreta.trim().toLowerCase() ? "correto" : "incorreto",
    };
  } catch (error) {
    throw new functions.https.HttpsError("internal", "Erro ao verificar a resposta.", error.message);
  }
});




// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
