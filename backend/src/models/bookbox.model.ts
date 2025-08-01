import mongoose from 'mongoose';

const bookSchema = new mongoose.Schema({
   isbn: { type: String },
   title: { type: String, required: true },
   authors: [String],
   description: String,
   coverImage: String,
   publisher: String,
   categories: [String],
   parutionYear: Number,
   pages: Number,
   dateAdded: { type: Date, default: Date.now }
});

const bookboxSchema = new mongoose.Schema({
   name: { type: String, required: true },
   owner: { type: String, required: true },
   image: String,
   longitude: { type: Number, required: true },
   latitude: { type: Number, required: true },
   boroughId: { type: String, required: true },
   booksCount: { type: Number, default: 0 },
   location: {
       type: { type: String, default: 'Point' },
       coordinates: [Number] // [longitude, latitude]
   },
   infoText: String,
   books: [bookSchema],
   isActive: { type: Boolean, default: true },
});

bookboxSchema.pre('save', function(next) {
   // Always sync booksCount with books array length
   this.booksCount = this.books.length;
   
   // Sync location coordinates
   this.location = {
       type: 'Point',
       coordinates: [this.longitude, this.latitude]
   };
   
   next();
});

// INDEXES FOR NESTED BOOKS SEARCHING
bookboxSchema.index({
   "books.title": "text",
   "books.authors": "text", 
   "books.categories": "text"
});

bookboxSchema.index({ "books.title": 1 });
bookboxSchema.index({ "books.authors": 1 });
bookboxSchema.index({ "books.parutionYear": 1 });
bookboxSchema.index({ "books.dateAdded": 1 });
bookboxSchema.index({ "books._id": 1 });

// BOOKBOX-LEVEL INDEXES
bookboxSchema.index({ owner: 1 });
bookboxSchema.index({ isActive: 1 });
bookboxSchema.index({ boroughId: 1 });
bookboxSchema.index({ booksCount: 1 });
bookboxSchema.index({ name: 1 });

// GEOSPATIAL INDEX FOR LOCATION QUERIES
bookboxSchema.index({ location: '2dsphere' });

// COMPOUND INDEXES FOR COMMON QUERY PATTERNS
// Public search (active bookboxes with sorting)
bookboxSchema.index({ isActive: 1, booksCount: -1 });
bookboxSchema.index({ isActive: 1, name: 1 });

// Owner management queries
bookboxSchema.index({ owner: 1, isActive: 1 });
bookboxSchema.index({ owner: 1, name: 1 });

// Borough-based searches
bookboxSchema.index({ boroughId: 1, isActive: 1 });
bookboxSchema.index({ boroughId: 1, booksCount: -1 });

// Text search with activity filter
bookboxSchema.index({ isActive: 1, name: "text", infoText: "text" });

const BookBox = mongoose.model('BookBox', bookboxSchema, "bookboxes");

export default BookBox;