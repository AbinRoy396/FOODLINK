# FoodLink Database Schema

## Enhanced Database Fields for Complete Food Donation System

### 1. DONATIONS Table (Enhanced)

**Core Fields:**
- `id` (Primary Key)
- `donor_id` (Foreign Key to users)
- `donor_name`
- `food_type`
- `category`
- `quantity`
- `description`
- `expiry_date`
- `pickup_address`
- `status`
- `created_at`

**Additional Database Fields:**
- `donor_phone` - Contact number for coordination
- `donor_email` - Email for notifications
- `latitude` - GPS coordinates for mapping
- `longitude` - GPS coordinates for mapping
- `image_urls` - JSON array of food photos
- `allergen_info` - Allergen warnings
- `storage_instructions` - How to store the food
- `serving_size` - Number of people it can serve
- `nutritional_info` - Nutritional details
- `is_halal` - Boolean for halal certification
- `is_vegan` - Boolean for vegan food
- `is_gluten_free` - Boolean for gluten-free
- `priority` - Urgency level (Low/Medium/High/Urgent)
- `pickup_time_start` - Available pickup start time
- `pickup_time_end` - Available pickup end time
- `last_updated` - Last modification timestamp
- `verified_by` - NGO user ID who verified
- `verified_at` - Verification timestamp
- `allocated_to` - Receiver ID if allocated
- `allocated_at` - Allocation timestamp
- `rejection_reason` - Reason if rejected
- `estimated_value` - Monetary value estimate
- `donation_source` - Source type (Restaurant/Individual/Event/Store)
- `view_count` - Number of times viewed
- `request_count` - Number of requests received

### 2. REQUESTS Table (Enhanced)

**Core Fields:**
- `id` (Primary Key)
- `receiver_id` (Foreign Key to users)
- `food_type`
- `quantity`
- `address`
- `notes`
- `status`
- `created_at`

**Additional Database Fields:**
- `receiver_name` - Contact name
- `receiver_phone` - Contact number
- `receiver_email` - Email for notifications
- `latitude` - GPS coordinates
- `longitude` - GPS coordinates
- `urgency_level` - Priority (Low/Medium/High/Critical)
- `family_size` - Number of people to feed
- `dietary_restrictions` - Special dietary needs
- `needs_halal` - Boolean for halal requirement
- `needs_vegan` - Boolean for vegan requirement
- `needs_gluten_free` - Boolean for gluten-free requirement
- `needed_by` - Deadline for fulfillment
- `preferred_pickup_time` - Preferred time slot
- `matched_donation_id` - ID of matched donation
- `matched_at` - Matching timestamp
- `matched_by` - NGO user ID who made match
- `fulfilled_at` - Fulfillment timestamp
- `cancellation_reason` - Reason if cancelled
- `last_updated` - Last modification timestamp
- `special_instructions` - Additional instructions
- `max_travel_distance` - Maximum travel distance (km)
- `transportation_method` - How they'll collect food
- `view_count` - Number of times viewed
- `request_source` - Source (Mobile App/Website/Phone/Walk-in)

### 3. USERS Table (Enhanced)

**Existing Fields:**
- `id`, `name`, `email`, `password`, `phone`, `user_type`, `created_at`

**Additional Database Fields:**
- `profile_image_url` - Profile photo
- `address` - Full address
- `latitude` - GPS coordinates
- `longitude` - GPS coordinates
- `date_of_birth` - Age verification
- `gender` - Demographics
- `preferred_language` - Localization
- `notification_preferences` - JSON of preferences
- `is_verified` - Account verification status
- `verification_method` - How they were verified
- `last_login` - Last login timestamp
- `login_count` - Total login count
- `account_status` - Active/Inactive/Suspended
- `organization_id` - Link to organization (for NGO users)
- `total_donations` - Count of donations made
- `total_requests` - Count of requests made
- `success_rate` - Percentage of successful transactions
- `average_rating` - User rating from feedback
- `emergency_contact` - Emergency contact info
- `dietary_preferences` - Personal dietary info
- `volunteer_availability` - For volunteer coordination

### 4. ORGANIZATIONS Table (New)

- `id` (Primary Key)
- `name` - Organization name
- `type` - NGO/Restaurant/Grocery Store/Food Bank
- `description` - About the organization
- `address` - Physical address
- `latitude` - GPS coordinates
- `longitude` - GPS coordinates
- `phone` - Contact number
- `email` - Contact email
- `website` - Website URL
- `registration_number` - Legal registration
- `is_verified` - Verification status
- `verified_at` - Verification timestamp
- `verified_by` - Who verified them
- `status` - Active/Inactive/Suspended
- `service_areas` - JSON array of areas served
- `operating_hours` - JSON of operating schedule
- `logo_url` - Organization logo
- `certifications` - JSON array of certifications
- `created_at` - Registration date
- `last_updated` - Last modification
- `total_donations_handled` - Statistics
- `total_requests_fulfilled` - Statistics
- `average_rating` - Rating from feedback

### 5. INVENTORY Table (New)

- `id` (Primary Key)
- `organization_id` (Foreign Key)
- `item_name` - Food item name
- `category` - Food category
- `quantity` - Current quantity
- `unit` - Unit of measurement
- `expiry_date` - Expiration date
- `condition` - Fresh/Good/Near Expiry
- `storage_location` - Where it's stored
- `temperature` - Storage temperature
- `batch_number` - Batch tracking
- `received_at` - When received
- `received_from_donation_id` - Source donation
- `is_allocated` - Allocation status
- `allocated_to_request_id` - Target request
- `allocated_at` - Allocation timestamp
- `notes` - Additional notes

### 6. NOTIFICATIONS Table (New)

- `id` (Primary Key)
- `user_id` (Foreign Key)
- `title` - Notification title
- `message` - Notification content
- `type` - Type of notification
- `is_read` - Read status
- `action_data` - JSON for app actions
- `created_at` - Creation timestamp
- `read_at` - Read timestamp
- `priority` - Low/Medium/High

### 7. ANALYTICS Table (New)

- `id` (Primary Key)
- `event_type` - Type of event tracked
- `user_id` - User who triggered event
- `donation_id` - Related donation
- `request_id` - Related request
- `metadata` - JSON of additional data
- `timestamp` - When event occurred
- `session_id` - User session
- `device_info` - Device information
- `location` - Geographic location

### 8. FEEDBACK Table (New)

- `id` (Primary Key)
- `user_id` (Foreign Key)
- `user_type` - Donor/Receiver/NGO
- `donation_id` - Related donation
- `request_id` - Related request
- `rating` - 1-5 star rating
- `comment` - Text feedback
- `category` - Feedback category
- `created_at` - Feedback timestamp
- `is_anonymous` - Anonymous feedback flag
- `improvement_suggestions` - Suggestions

## Benefits of Enhanced Schema

### 1. **Better Matching Algorithm**
- GPS coordinates for distance-based matching
- Dietary preferences and restrictions
- Urgency levels and deadlines
- Food categories and allergen info

### 2. **Improved User Experience**
- Rich food photos and descriptions
- Real-time notifications
- Pickup time coordination
- Progress tracking

### 3. **Analytics & Insights**
- User behavior tracking
- Success rate monitoring
- Geographic distribution analysis
- Food waste reduction metrics

### 4. **Operational Efficiency**
- Inventory management for NGOs
- Automated matching algorithms
- Performance monitoring
- Quality assurance tracking

### 5. **Scalability**
- Organization management
- Multi-location support
- Volunteer coordination
- Partnership integration

This enhanced schema provides a solid foundation for a comprehensive food donation platform while maintaining backward compatibility with your existing frontend.
