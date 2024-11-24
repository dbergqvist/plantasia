package models

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type WateringEvent struct {
	ID        primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	Timestamp time.Time          `bson:"timestamp" json:"timestamp"`
	Name      string             `bson:"name" json:"name"`
}
