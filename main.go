package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"os"
	"time"

	"plantasia/internal/handlers"

	"github.com/gorilla/mux"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func main() {
	// Add this at the start of main()
	log.SetFlags(log.LstdFlags | log.Lshortfile)

	// Connect to MongoDB
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Get MongoDB credentials from environment
	mongoUser := os.Getenv("MONGODB_USER")
	mongoPass := os.Getenv("MONGODB_PASSWORD")
	mongoHost := os.Getenv("MONGODB_HOST")

	mongoURI := fmt.Sprintf("mongodb://%s:%s@%s:27017/plantasia?authSource=admin",
		mongoUser,
		url.QueryEscape(mongoPass),
		mongoHost,
	)

	client, err := mongo.Connect(ctx, options.Client().ApplyURI(mongoURI))
	if err != nil {
		log.Fatal(err)
	}
	defer client.Disconnect(ctx)

	// Test MongoDB connection
	err = client.Ping(ctx, nil)
	if err != nil {
		log.Printf("MongoDB connection error: %v", err)
		log.Fatal(err)
	}
	log.Printf("Successfully connected to MongoDB")

	collection := client.Database("plantasia").Collection("plants")

	// Initialize router and handlers
	r := mux.NewRouter()
	h := handlers.NewHandler(collection)

	// Routes
	r.HandleFunc("/api/water", h.AddWateringEvent).Methods("POST")
	r.HandleFunc("/api/water", h.GetWateringEvents).Methods("GET")
	r.PathPrefix("/").Handler(http.FileServer(http.Dir("static")))

	log.Println("Server starting on :8080")
	log.Fatal(http.ListenAndServe(":8080", r))
}
