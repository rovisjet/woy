from django.core.management.base import BaseCommand
from django.db import transaction
from woy.models import Ring, RingEra, RingImage
import json

class Command(BaseCommand):
    help = 'Loads initial ring data'

    @transaction.atomic
    def handle(self, *args, **options):
        self.stdout.write('Deleting existing rings data...')
        Ring.objects.all().delete()
        
        self.stdout.write('Loading rings data...')
        
        # Menstrual Cycle
        menstrual_ring = Ring.objects.create(
            index=0,
            name='Menstrual Cycle',
            inner_radius=50.0,
            thickness=20.0,
            number_of_ticks=28,
            base_color='#E91E63',
            use_images=False
        )
        
        RingEra.objects.create(
            ring=menstrual_ring,
            name='Menstrual',
            description='Menstrual phase',
            start_day=0,
            end_day=5,
            color='#F48FB1'
        )
        
        RingEra.objects.create(
            ring=menstrual_ring,
            name='Follicular',
            description='Follicular phase',
            start_day=5,
            end_day=14,
            color='#EC407A'
        )
        
        RingEra.objects.create(
            ring=menstrual_ring,
            name='Ovulation',
            description='Ovulation phase',
            start_day=14,
            end_day=16,
            color='#D81B60'
        )
        
        RingEra.objects.create(
            ring=menstrual_ring,
            name='Luteal',
            description='Luteal phase',
            start_day=16,
            end_day=28,
            color='#AD1457'
        )
        
        # Moon Cycle
        moon_ring = Ring.objects.create(
            index=1,
            name='Moon Cycle',
            inner_radius=80.0,
            thickness=20.0,
            number_of_ticks=29,
            base_color='#2196F3',
            use_images=False
        )
        
        RingEra.objects.create(
            ring=moon_ring,
            name='New Moon',
            description='New Moon phase',
            start_day=0,
            end_day=3.6,
            color='#90CAF9'
        )
        
        RingEra.objects.create(
            ring=moon_ring,
            name='Waxing Crescent',
            description='Waxing Crescent phase',
            start_day=3.6,
            end_day=7.4,
            color='#64B5F6'
        )
        
        RingEra.objects.create(
            ring=moon_ring,
            name='First Quarter',
            description='First Quarter phase',
            start_day=7.4,
            end_day=11.1,
            color='#42A5F5'
        )
        
        RingEra.objects.create(
            ring=moon_ring,
            name='Waxing Gibbous',
            description='Waxing Gibbous phase',
            start_day=11.1,
            end_day=14.8,
            color='#2196F3'
        )
        
        RingEra.objects.create(
            ring=moon_ring,
            name='Full Moon',
            description='Full Moon phase',
            start_day=14.8,
            end_day=18.5,
            color='#1976D2'
        )
        
        RingEra.objects.create(
            ring=moon_ring,
            name='Waning Gibbous',
            description='Waning Gibbous phase',
            start_day=18.5,
            end_day=21.7,
            color='#1565C0'
        )
        
        RingEra.objects.create(
            ring=moon_ring,
            name='Last Quarter',
            description='Last Quarter phase',
            start_day=21.7,
            end_day=25.3,
            color='#0D47A1'
        )
        
        RingEra.objects.create(
            ring=moon_ring,
            name='Waning Crescent',
            description='Waning Crescent phase',
            start_day=25.3,
            end_day=29,
            color='#82B1FF'
        )
        
        # Moon Phases (Images)
        moon_phases_ring = Ring.objects.create(
            index=2,
            name='Moon Phases',
            inner_radius=110.0,
            thickness=20.0,
            number_of_ticks=8,
            base_color='#2196F3',
            use_images=True
        )
        
        moon_phase_images = [
            'assets/images/moon/new_moon.svg',
            'assets/images/moon/waxing_crescent.svg',
            'assets/images/moon/first_quarter.svg',
            'assets/images/moon/waxing_gibbous.svg',
            'assets/images/moon/full_moon.svg',
            'assets/images/moon/waning_gibbous.svg',
            'assets/images/moon/last_quarter.svg',
            'assets/images/moon/waning_crescent.svg',
        ]
        
        for i, image_path in enumerate(moon_phase_images):
            RingImage.objects.create(
                ring=moon_phases_ring,
                image_path=image_path,
                order=i
            )
        
        # Year
        year_ring = Ring.objects.create(
            index=3,
            name='Year',
            inner_radius=140.0,
            thickness=20.0,
            number_of_ticks=365,
            base_color='#4CAF50',
            use_images=False
        )
        
        RingEra.objects.create(
            ring=year_ring,
            name='Spring',
            description='Spring season',
            start_day=0,
            end_day=91.25,
            color='#A5D6A7'
        )
        
        RingEra.objects.create(
            ring=year_ring,
            name='Summer',
            description='Summer season',
            start_day=91.25,
            end_day=182.5,
            color='#66BB6A'
        )
        
        RingEra.objects.create(
            ring=year_ring,
            name='Fall',
            description='Fall season',
            start_day=182.5,
            end_day=273.75,
            color='#43A047'
        )
        
        RingEra.objects.create(
            ring=year_ring,
            name='Winter',
            description='Winter season',
            start_day=273.75,
            end_day=365,
            color='#2E7D32'
        )
        
        self.stdout.write(self.style.SUCCESS('Successfully loaded rings data')) 