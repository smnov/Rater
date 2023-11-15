# 



Structure:
    Frontend with features:
        Rate photos of USERS
    Frontend downloads photo of 10 people
    
    Tabs: profile, photos of others, how app is working. emphasize the anonymous factor
        
structures:
    USER has
        KARMA
        PHOTO
            has rating
            
            
PHOTO 
    id
    user (one to many relationship)
    active (bool)
    rating
    
    
USER 
    id
    name
    email
    password
    photos
    gender
    age (date of birth)
