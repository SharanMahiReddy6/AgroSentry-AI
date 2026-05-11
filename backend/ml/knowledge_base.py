DISEASE_KNOWLEDGE = {
    "Apple___Apple_scab": {
        "common_name": "Apple Scab",
        "scientific_name": "Venturia inaequalis",
        "crop_type": "Apple",
        "overview": "A common fungal disease causing dark, velvety spots on leaves and scabby lesions on fruit.",
        "causes": ["High humidity (above 85%)", "Poor air circulation", "Wet leaf surfaces for 9+ hours", "Poor soil drainage"],
        "symptoms": [
            {"title": "Velvety Spots", "description": "Olive-green to black spots on the underside of leaves."},
            {"title": "Scabby Lesions", "description": "Dark, corky lesions developing on the fruit surface."},
            {"title": "Leaf Distortion", "description": "Leaves may pucker or curl as the infection spreads."},
            {"title": "Early Drop", "description": "Severely infected leaves turn yellow and fall prematurely."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"title": "Neem Oil", "description": "Apply 5ml/L every 7 days to coat leaf surfaces."},
                    {"title": "Pruning", "description": "Remove any leaves showing early signs of spots."}
                ],
                "chemical": {
                    "name": "Myclobutanil",
                    "strength": "Mild",
                    "description": "A protective fungicide that prevents fungal spores from germinating.",
                    "dosage": "1.5g / Liter"
                },
                "preventive": [
                    "Prune trees to improve air flow",
                    "Clear fallen leaves in autumn",
                    "Choose scab-resistant varieties",
                    "Avoid overhead irrigation"
                ]
            },
            "Moderate": {
                "organic": [
                    {"title": "Copper Spray", "description": "Apply liquid copper fungicide every 10 days."},
                    {"title": "Heavy Pruning", "description": "Thin out the canopy to increase sunlight and air flow."}
                ],
                "chemical": {
                    "name": "Captan 50 WP",
                    "strength": "Medium",
                    "description": "Multi-site protective fungicide for broader control.",
                    "dosage": "2g / Liter"
                },
                "preventive": [
                    "Sanitize pruning tools with alcohol",
                    "Improve soil drainage",
                    "Monitor weather for high-risk wet periods"
                ]
            },
            "High": {
                "organic": [
                    {"title": "Sulfur Dusting", "description": "Use wettable sulfur to suppress heavy fungal loads."},
                    {"title": "Total Sanitation", "description": "Remove and burn all heavily infected branches."}
                ],
                "chemical": {
                    "name": "Tebuconazole",
                    "strength": "Strong",
                    "description": "Systemic fungicide that travels through the plant to stop active rot.",
                    "dosage": "3g / Liter"
                },
                "preventive": [
                    "Complete orchard cleanup",
                    "Deep tillage to bury spores",
                    "Strict chemical rotation plan"
                ]
            }
        }
    },
    "Apple___Black_rot": {
        "common_name": "Black Rot",
        "scientific_name": "Botryosphaeria obtusa",
        "crop_type": "Apple",
        "overview": "Causes 'frog-eye' leaf spots and mummified fruit that stays on the tree.",
        "causes": ["Warm, wet spring weather", "Dead wood in the canopy", "Insect wounds on fruit", "High humidity"],
        "symptoms": [
            {"title": "Frog-eye Spots", "description": "Small purple spots with light tan centers."},
            {"title": "Black Fruit Rot", "description": "Fruit turns black and shrivels into 'mummies'."},
            {"title": "Cankers", "description": "Sunken brown areas on bark and branches."},
            {"title": "Yellowing", "description": "Leaves turn yellow between the veins and drop."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"title": "Sanitation", "description": "Remove any mummified fruit immediately."},
                    {"title": "Deadwood Removal", "description": "Cut out small dead twigs where fungus hides."}
                ],
                "chemical": {
                    "name": "Sulfur",
                    "strength": "Mild",
                    "description": "Protective spray to prevent spore attachment.",
                    "dosage": "5g / Liter"
                },
                "preventive": [
                    "Remove mummified fruit from trees",
                    "Prune dead wood during dormancy",
                    "Control insects to prevent wounds"
                ]
            },
            "Moderate": {
                "organic": [
                    {"title": "Lime Sulfur", "description": "Apply during late dormancy to kill overwintering spores."},
                    {"title": "Airflow", "description": "Thin the canopy for better spray penetration."}
                ],
                "chemical": {
                    "name": "Mancozeb",
                    "strength": "Medium",
                    "description": "Broad-spectrum fungicide for leaf and fruit protection.",
                    "dosage": "2g / Liter"
                },
                "preventive": [
                    "Clean orchard floor of debris",
                    "Avoid overhead watering"
                ]
            },
            "High": {
                "organic": [
                    {"title": "Burning", "description": "Burn all infected wood and fruit to destroy the fungus."},
                    {"title": "Replacement", "description": "Replace severely cankered trees."}
                ],
                "chemical": {
                    "name": "Thiophanate-methyl",
                    "strength": "Strong",
                    "description": "Potent systemic fungicide for heavy infections.",
                    "dosage": "2.5g / Liter"
                },
                "preventive": [
                    "Professional sanitation program",
                    "Resistant variety planting"
                ]
            }
        }
    },
    "Tomato___Early_blight": {
        "common_name": "Leaf Blight",
        "scientific_name": "Alternaria solani",
        "crop_type": "Tomato",
        "overview": "Early blight is a common tomato disease caused by the fungus Alternaria solani. It can affect almost all parts of the tomato plant.",
        "causes": ["Warm temperatures (24-29°C)", "High humidity or rainfall", "Crowded planting", "Poor soil nutrition"],
        "symptoms": [
            {"title": "Brown Spots", "description": "Small dark spots on older leaves that enlarge into rings."},
            {"title": "Yellow Halos", "description": "Yellowing of tissue surrounding the brown spots."},
            {"title": "Stem Lesions", "description": "Dark, sunken areas on the stem near the soil line."},
            {"title": "Fruit Rot", "description": "Leathery black spots near the stem end of the fruit."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"title": "Baking Soda Spray", "description": "Mix 1 tbsp baking soda with 1L water."},
                    {"title": "Mulching", "description": "Add 2 inches of mulch to prevent soil splashing."}
                ],
                "chemical": {
                    "name": "Chlorothalonil",
                    "strength": "Mild",
                    "description": "Protective coating to prevent spore germination.",
                    "dosage": "1g / Liter"
                },
                "preventive": [
                    "Rotate crops every 2-3 years",
                    "Use drip irrigation",
                    "Space plants for airflow"
                ]
            },
            "Moderate": {
                "organic": [
                    {"title": "Neem Oil Spray", "description": "Mix 5ml of neem oil per liter of water. Spray every 3 days."},
                    {"title": "Pruning", "description": "Remove and destroy lower infected leaves."}
                ],
                "chemical": {
                    "name": "Copper Fungicide",
                    "strength": "Strong",
                    "description": "Effective against early blight. Apply every 7-10 days.",
                    "dosage": "2g / Liter"
                },
                "preventive": [
                    "Rotate crops every 2-3 years",
                    "Use drip irrigation to keep foliage dry",
                    "Space plants properly for airflow",
                    "Mulch soil to prevent spore splash"
                ]
            },
            "High": {
                "organic": [
                    {"title": "Bio-Fungicides", "description": "Use Bacillus subtilis based organic sprays."},
                    {"title": "Total Removal", "description": "Pull out and burn heavily infected plants."}
                ],
                "chemical": {
                    "name": "Azoxystrobin",
                    "strength": "Strong",
                    "description": "Systemic treatment for severe outbreaks.",
                    "dosage": "3g / Liter"
                },
                "preventive": [
                    "Deep soil solarization",
                    "Complete removal of garden debris"
                ]
            }
        }
    },
    "Apple___Cedar_apple_rust": {
        "common_name": "Cedar Apple Rust",
        "scientific_name": "Gymnosporangium juniperi-virginianae",
        "crop_type": "Apple",
        "overview": "A complex fungal disease that requires both apple trees and red cedars to complete its life cycle.",
        "causes": ["Proximity to red cedar trees", "Wet spring weather", "Wind-blown spores", "Warm temperatures"],
        "symptoms": [
            {"title": "Orange Spots", "description": "Bright yellow-orange spots appearing on the upper leaf surface."},
            {"title": "Black Dots", "description": "Small black fungal bodies forming within the orange spots."},
            {"title": "Tube Structures", "description": "Fungal tubes appearing on the underside of the leaf."},
            {"title": "Fruit Lesions", "description": "Yellow-orange lesions on the blossom end of the fruit."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"title": "Cedar Removal", "description": "Remove any nearby red cedar galls in early spring."},
                    {"title": "Resistant Cultivars", "description": "Focus on planting rust-resistant apple varieties."}
                ],
                "chemical": {
                    "name": "Immunox",
                    "strength": "Mild",
                    "description": "Systemic fungicide specifically effective against rusts.",
                    "dosage": "1.5g / Liter"
                },
                "preventive": ["Prune for airflow", "Remove nearby cedar galls"]
            },
            "Moderate": {
                "organic": [
                    {"title": "Sulfur Spray", "description": "Apply wettable sulfur at the first sign of orange spots."},
                    {"title": "Leaf Pruning", "description": "Remove leaves with heavy rust spotting."}
                ],
                "chemical": {
                    "name": "Myclobutanil",
                    "strength": "Medium",
                    "description": "Systemic treatment for active rust infections.",
                    "dosage": "2g / Liter"
                },
                "preventive": ["Avoid overhead watering", "Sanitize tools"]
            },
            "High": {
                "organic": [
                    {"title": "Total Sanitation", "description": "Burn all infected wood and fruit to destroy fungus."}
                ],
                "chemical": {
                    "name": "Mancozeb",
                    "strength": "Strong",
                    "description": "Broad-spectrum protection to stop spore spread.",
                    "dosage": "3g / Liter"
                },
                "preventive": ["Complete host removal", "Protective spray program"]
            }
        }
    },
    "Potato___Late_blight": {
        "common_name": "Late Blight",
        "scientific_name": "Phytophthora infestans",
        "crop_type": "Potato",
        "overview": "A highly destructive disease that spreads rapidly in cool, wet weather.",
        "causes": ["Cool temperatures", "High humidity", "Infected seed tubers", "Frequent rainfall"],
        "symptoms": [
            {"title": "Watery Spots", "description": "Dark green, water-soaked spots on leaf tips/margins."},
            {"title": "White Mold", "description": "White fungal growth on the underside of leaves."},
            {"title": "Stem Cankers", "description": "Dark brown lesions on stems and petioles."},
            {"title": "Tuber Rot", "description": "Brown, corky rot developing in the potato tubers."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"title": "Copper Spray", "description": "Apply copper-based fungicides immediately."},
                    {"title": "Isolate", "description": "Remove any plant showing single spots."}
                ],
                "chemical": {
                    "name": "Chlorothalonil",
                    "strength": "Medium",
                    "description": "Protective barrier to prevent infection.",
                    "dosage": "1.5g / Liter"
                },
                "preventive": ["Use certified seeds", "Avoid overhead irrigation"]
            },
            "Moderate": {
                "organic": [
                    {"title": "Heavy Pruning", "description": "Remove all lower foliage to increase air flow."},
                    {"title": "Bacillus Sprays", "description": "Use organic bacterial sprays like Serenade."}
                ],
                "chemical": {
                    "name": "Mancozeb + Metalaxyl",
                    "strength": "Strong",
                    "description": "Combined systemic and contact protection.",
                    "dosage": "2.5g / Liter"
                },
                "preventive": ["Crop rotation", "Resistant varieties"]
            },
            "High": {
                "organic": [
                    {"title": "Burn Vines", "description": "Kill the vines immediately to save the tubers."}
                ],
                "chemical": {
                    "name": "Azoxystrobin",
                    "strength": "Critical",
                    "description": "Strongest systemic fungicide for epidemic control.",
                    "dosage": "3.5g / Liter"
                },
                "preventive": ["Regional monitoring", "Immediate vine destruction"]
            }
        }
    }
}

def get_disease_info(class_name, severity="Low"):
    # Fallback to generic if specific class not found
    info = DISEASE_KNOWLEDGE.get(class_name)
    if not info:
        # Default fallback for classes not yet in KB
        return {
            "common_name": class_name.split("___")[-1].replace("_", " "),
            "scientific_name": "N/A",
            "crop_type": class_name.split("___")[0],
            "overview": "No detailed information available.",
            "causes": ["Environmental stress", "Pathogen exposure"],
            "symptoms": [{"title": "Visible Lesions", "description": "Abnormal spots or color changes on the leaf surface."}],
            "organic_treatment": [{"title": "Monitoring", "description": "Observe and isolate infected plants."}],
            "chemical_treatment": {"name": "General Fungicide", "strength": "Mild", "description": "Standard protective spray.", "dosage": "1g/L"},
            "prevention": ["Maintain plant health", "Ensure proper spacing"]
        }
    
    # Select treatment based on severity
    treatment_data = info["treatments"].get(severity, info["treatments"]["Low"])
    
    return {
        "common_name": info["common_name"],
        "scientific_name": info["scientific_name"],
        "crop_type": info["crop_type"],
        "overview": info["overview"],
        "causes": info["causes"],
        "symptoms": info["symptoms"],
        "organic_treatment": treatment_data["organic"],
        "chemical_treatment": treatment_data["chemical"],
        "prevention": treatment_data["preventive"]
    }
