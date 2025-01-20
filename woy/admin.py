from django.contrib import admin
from django import forms
from .models import Circle, Era, Event

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
