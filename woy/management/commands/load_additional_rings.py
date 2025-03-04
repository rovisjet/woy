from django.core.management.base import BaseCommand
from django.db import transaction
from woy.models import Ring, RingEra, RingImage
import random
import colorsys

class Command(BaseCommand):
    help = 'Loads additional public rings data with diverse characteristics'

    def add_arguments(self, parser):
        parser.add_argument('--count', type=int, default=10, help='Number of rings to generate')

    def generate_random_color(self):
        # Generate a pleasing random color in HSV, then convert to RGB
        h = random.random()  # random hue
        s = 0.6 + random.random() * 0.4  # saturation 0.6-1.0
        v = 0.6 + random.random() * 0.4  # value 0.6-1.0
        
        r, g, b = colorsys.hsv_to_rgb(h, s, v)
        # Convert to hex string
        return f'#{int(r*255):02x}{int(g*255):02x}{int(b*255):02x}'

    def generate_lighter_color(self, base_color_hex, factor=0.2):
        # Extract RGB values from hex
        r = int(base_color_hex[1:3], 16) / 255.0
        g = int(base_color_hex[3:5], 16) / 255.0
        b = int(base_color_hex[5:7], 16) / 255.0
        
        # Convert to HSV
        h, s, v = colorsys.rgb_to_hsv(r, g, b)
        
        # Make it lighter by reducing saturation and increasing value
        s = max(0, s - factor)
        v = min(1.0, v + factor)
        
        # Convert back to RGB
        r, g, b = colorsys.hsv_to_rgb(h, s, v)
        
        # Convert to hex
        return f'#{int(r*255):02x}{int(g*255):02x}{int(b*255):02x}'

    def generate_darker_color(self, base_color_hex, factor=0.2):
        # Extract RGB values from hex
        r = int(base_color_hex[1:3], 16) / 255.0
        g = int(base_color_hex[3:5], 16) / 255.0
        b = int(base_color_hex[5:7], 16) / 255.0
        
        # Convert to HSV
        h, s, v = colorsys.rgb_to_hsv(r, g, b)
        
        # Make it darker by increasing saturation and reducing value
        s = min(1.0, s + factor)
        v = max(0, v - factor)
        
        # Convert back to RGB
        r, g, b = colorsys.hsv_to_rgb(h, s, v)
        
        # Convert to hex
        return f'#{int(r*255):02x}{int(g*255):02x}{int(b*255):02x}'

    def create_diverse_eras(self, ring, num_eras):
        # Generate a different number of eras for each ring
        era_names = [
            "Beginning", "Growth", "Peak", "Decline", "Renewal",
            "Dawn", "Morning", "Noon", "Afternoon", "Evening", "Night",
            "Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta",
            "Spring", "Summer", "Autumn", "Winter",
            "Waxing", "Full", "Waning", "New",
            "First Phase", "Second Phase", "Third Phase", "Fourth Phase", "Fifth Phase",
            "Genesis", "Ascent", "Zenith", "Descent", "Nadir",
            "Seedling", "Sprouting", "Blooming", "Fruiting", "Withering",
            "Water", "Wood", "Fire", "Earth", "Metal"
        ]
        
        # Shuffle and pick names for this ring
        random.shuffle(era_names)
        selected_names = era_names[:num_eras]
        
        # Calculate days per era
        days_per_era = ring.number_of_ticks / num_eras
        
        # Get base color for variations
        base_color = ring.base_color
        
        # Create eras
        for i in range(num_eras):
            start_day = i * days_per_era
            end_day = (i + 1) * days_per_era
            
            # Alternate between lighter and darker variations of base color
            if i % 3 == 0:
                color = self.generate_lighter_color(base_color, 0.3)
            elif i % 3 == 1:
                color = base_color
            else:
                color = self.generate_darker_color(base_color, 0.3)
            
            RingEra.objects.create(
                ring=ring,
                name=selected_names[i],
                description=f"{selected_names[i]} phase of the {ring.name}",
                start_day=start_day,
                end_day=end_day,
                color=color
            )

    @transaction.atomic
    def handle(self, *args, **options):
        ring_count = options['count']
        
        self.stdout.write(f'Generating {ring_count} additional public rings...')
        
        # Get the highest existing index
        highest_index = Ring.objects.order_by('-index').first()
        start_index = highest_index.index + 1 if highest_index else 0
        
        # Example ring types with diverse characteristics
        ring_types = [
            {
                "name_prefix": "Biorhythm",
                "days_range": (21, 33),
                "eras_range": (3, 5),
                "desc": "Tracks physical, emotional, and intellectual cycles"
            },
            {
                "name_prefix": "Zodiac",
                "days_range": (360, 366),
                "eras_range": (12, 12),
                "desc": "Based on astrological signs"
            },
            {
                "name_prefix": "Seasonal",
                "days_range": (90, 120),
                "eras_range": (3, 6),
                "desc": "Represents seasonal changes"
            },
            {
                "name_prefix": "Lunar",
                "days_range": (28, 30),
                "eras_range": (4, 8),
                "desc": "Based on moon phases"
            },
            {
                "name_prefix": "Solar",
                "days_range": (300, 366),
                "eras_range": (4, 12),
                "desc": "Based on solar calendar"
            },
            {
                "name_prefix": "Cosmic",
                "days_range": (50, 400),
                "eras_range": (5, 9),
                "desc": "Connected to celestial events"
            },
            {
                "name_prefix": "Elemental",
                "days_range": (15, 60),
                "eras_range": (4, 5),
                "desc": "Based on elemental cycles"
            },
            {
                "name_prefix": "Agricultural",
                "days_range": (90, 180),
                "eras_range": (4, 7),
                "desc": "Follows planting and harvesting cycles"
            },
            {
                "name_prefix": "Cultural",
                "days_range": (30, 360),
                "eras_range": (3, 12),
                "desc": "Based on cultural festivals and traditions"
            },
            {
                "name_prefix": "Mythological",
                "days_range": (30, 100),
                "eras_range": (3, 7),
                "desc": "Inspired by mythological cycles"
            }
        ]
        
        # Define custom suffixes/variations to create unique names
        suffixes = ["Cycle", "Calendar", "Phase", "System", "Period", "Rhythm", "Rotation", "Revolution", "Flow", "Wave"]
        variations = ["Traditional", "Modern", "Ancient", "Celestial", "Natural", "Spiritual", "Harmonic", "Balanced", "Mystic", "Eternal"]
        
        for i in range(ring_count):
            # Choose a random ring type
            ring_type = random.choice(ring_types)
            
            # Generate unique name
            if random.random() < 0.5:
                # Use suffix
                name = f"{ring_type['name_prefix']} {random.choice(suffixes)}"
            else:
                # Use variation
                name = f"{random.choice(variations)} {ring_type['name_prefix']}"
            
            # Make name unique if it already exists
            existing_count = Ring.objects.filter(name__startswith=name).count()
            if existing_count > 0:
                name = f"{name} {existing_count + 1}"
            
            # Generate random parameters within the type's range
            number_of_ticks = random.randint(ring_type['days_range'][0], ring_type['days_range'][1])
            num_eras = random.randint(ring_type['eras_range'][0], ring_type['eras_range'][1])
            
            # Generate pleasing color
            base_color = self.generate_random_color()
            
            # Calculate inner_radius and thickness (will be recalculated by frontend)
            inner_radius = 50.0 + i * 30.0
            thickness = 20.0
            
            # Create ring with the calculated values
            ring = Ring.objects.create(
                index=start_index + i,
                name=name,
                description=f"{ring_type['desc']}",
                inner_radius=inner_radius,
                thickness=thickness,
                number_of_ticks=number_of_ticks,
                base_color=base_color,
                use_images=False,
                is_public=True  # Make all rings public
            )
            
            # Create eras for the ring
            self.create_diverse_eras(ring, num_eras)
            
            self.stdout.write(f'Created: {name} with {num_eras} eras and {number_of_ticks} days')
        
        self.stdout.write(self.style.SUCCESS(f'Successfully created {ring_count} additional public rings')) 