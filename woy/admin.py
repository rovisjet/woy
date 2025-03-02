from django.contrib import admin
from django import forms
from .models import Circle, Era, Event, Ring, RingEra, RingImage

class CircleAdminForm(forms.ModelForm):
    class Meta:
        model = Circle
        fields = '__all__'

    color = forms.CharField(widget=forms.TextInput(attrs={'type': 'color'}))

class EraAdminForm(forms.ModelForm):
    class Meta:
        model = Era
        fields = '__all__'

    color = forms.CharField(widget=forms.TextInput(attrs={'type': 'color'}))

# Define an inline admin descriptor for the Era model
class EraInline(admin.TabularInline):
    model = Era
    form = EraAdminForm
    extra = 1  # Number of blank 'extra' forms shown
    fields = ['name', 'description', 'start_day', 'end_day', 'color']  # Customize displayed fields

# Define an inline admin descriptor for the Event model
class EventInline(admin.TabularInline):
    model = Event
    extra = 1  # Number of blank 'extra' forms shown
    fields = ['name', 'description', 'day', 'degree', 'image']  # Customize displayed fields

# Register Circle with nested inlines for Era and Event
@admin.register(Circle)
class CircleAdmin(admin.ModelAdmin):
    model = Circle
    form = CircleAdminForm
    list_display = ('name', 'description', 'days_in_cycle', 'repeats', 'color')
    inlines = [EraInline, EventInline]

# Ring admin
class RingAdminForm(forms.ModelForm):
    class Meta:
        model = Ring
        fields = '__all__'

    base_color = forms.CharField(widget=forms.TextInput(attrs={'type': 'color'}))

class RingEraAdminForm(forms.ModelForm):
    class Meta:
        model = RingEra
        fields = '__all__'

    color = forms.CharField(widget=forms.TextInput(attrs={'type': 'color'}))

class RingEraInline(admin.TabularInline):
    model = RingEra
    form = RingEraAdminForm
    extra = 1
    fields = ['name', 'description', 'start_day', 'end_day', 'color']

class RingImageInline(admin.TabularInline):
    model = RingImage
    extra = 1
    fields = ['image_path', 'order']

@admin.register(Ring)
class RingAdmin(admin.ModelAdmin):
    model = Ring
    form = RingAdminForm
    list_display = ('name', 'index', 'number_of_ticks', 'base_color', 'use_images')
    inlines = [RingEraInline, RingImageInline]
