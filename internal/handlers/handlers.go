package handlers

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"time"

	"plantasia/internal/models"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

type Handler struct {
	collection *mongo.Collection
}

func NewHandler(collection *mongo.Collection) *Handler {
	return &Handler{collection: collection}
}

func (h *Handler) AddWateringEvent(w http.ResponseWriter, r *http.Request) {
	log.Printf("Received watering event request")

	var event models.WateringEvent
	if err := json.NewDecoder(r.Body).Decode(&event); err != nil {
		log.Printf("Error decoding request: %v", err)
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	log.Printf("Decoded event: %+v", event)

	event.Timestamp = time.Now()

	result, err := h.collection.InsertOne(context.Background(), event)
	if err != nil {
		log.Printf("Error inserting event: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	log.Printf("Successfully inserted event with ID: %v", result.InsertedID)

	w.WriteHeader(http.StatusCreated)
}

func (h *Handler) GetWateringEvents(w http.ResponseWriter, r *http.Request) {
	log.Printf("Received get events request")

	var events []models.WateringEvent

	cursor, err := h.collection.Find(context.Background(), bson.M{})
	if err != nil {
		log.Printf("Error finding events: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer cursor.Close(context.Background())

	if err = cursor.All(context.Background(), &events); err != nil {
		log.Printf("Error decoding events: %v", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	log.Printf("Found %d events", len(events))

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(events)
}
