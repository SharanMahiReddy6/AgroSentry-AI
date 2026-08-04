DISEASE_KNOWLEDGE = {
    "Apple___Apple_scab": {
        "common_name": "Apple Scab",
        "scientific_name": "Venturia inaequalis",
        "crop_type": "Apple",
        "overview": "Apple scab is a major fungal disease affecting apple trees globally. The pathogen, Venturia inaequalis, overwinters in infected fallen leaves. Primary infection occurs in spring during wet weather when ascospores are released. It severely impacts fruit quality, leading to unmarketable yields and defoliation.",
        "causes": ["Extended leaf wetness (9+ hours) coupled with temperatures between 13°C and 24°C", "Overwintering inoculum (pseudothecia) in fallen leaf litter", "High canopy density limiting airflow and drying"],
        "symptoms": [
            {"title": "Velvety Lesions", "description": "Olive-green, velvety, irregular spots appearing on the undersides and upper surfaces of young leaves."},
            {"title": "Chlorosis and Curling", "description": "Heavily infected leaves turn yellow, pucker, and drop prematurely, causing severe defoliation."},
            {"title": "Fruit Scab", "description": "Cork-like, dark, scabby lesions on the fruit surface which can cause cracking as the fruit grows."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"step": 1, "title": "Sanitation", "description": "Rake and destroy fallen leaves in autumn, or shred them with a mower to accelerate decomposition."},
                    {"step": 2, "title": "Urea Application", "description": "Apply a 5% urea spray to fallen leaves to speed microbial breakdown of the fungus."}
                ],
                "chemical": {
                    "safetyMessage": "Apply preventative fungicides before rainfall events.",
                    "products": [{"name": "Captan 50 WP", "strength": "Mild", "description": "Protectant fungicide to inhibit spore germination.", "dosage": "2g / Liter"}]
                },
                "preventive": ["Plant scab-resistant cultivars (e.g., Enterprise, Liberty)", "Prune canopy for optimal air circulation"]
            },
            "Medium": {
                "organic": [
                    {"step": 1, "title": "Liquid Copper", "description": "Apply liquid copper octanoate during the green tip stage of bud development."},
                    {"step": 2, "title": "Sulfur Spray", "description": "Use wettable sulfur sprays every 7-10 days during high-risk spring periods."}
                ],
                "chemical": {
                    "safetyMessage": "Rotate chemical classes to prevent resistance.",
                    "products": [{"name": "Myclobutanil (Nova/Rally)", "strength": "Medium", "description": "Sterol inhibitor with some kickback activity (up to 96 hours post-infection).", "dosage": "1.5g / Liter"}]
                },
                "preventive": ["Implement a delayed dormant copper spray", "Monitor local leaf wetness data"]
            },
            "High": {
                "organic": [
                    {"step": 1, "title": "Aggressive Defoliation", "description": "Manually strip severely infected leaves to reduce secondary spore (conidia) spread."},
                    {"step": 2, "title": "Lime Sulfur", "description": "Apply lime sulfur carefully (can cause phytotoxicity in warm weather) as a strong eradicant."}
                ],
                "chemical": {
                    "safetyMessage": "Use systemic combinations; observe pre-harvest intervals closely.",
                    "products": [{"name": "Trifloxystrobin + Tebuconazole", "strength": "Strong", "description": "Broad-spectrum systemic and protectant action.", "dosage": "2.5g / Liter"}]
                },
                "preventive": ["Re-evaluate orchard layout", "Consider replacing highly susceptible trees if consistently unprofitable"]
            }
        }
    },
    "Apple___Black_rot": {
        "common_name": "Black Rot",
        "scientific_name": "Botryosphaeria obtusa",
        "crop_type": "Apple",
        "overview": "Black rot is a destructive disease affecting the leaves, fruit, and wood of apple trees. The pathogen survives in dead wood, cankers, and mummified fruit. Leaf symptoms are often termed 'frog-eye' leaf spot. It can cause total fruit loss if cankers are not managed.",
        "causes": ["Overwintering fungus in dead branches and mummified fruit", "Warm, wet weather during and after petal fall", "Wounds from insects or mechanical damage allowing fungal entry"],
        "symptoms": [
            {"title": "Frog-Eye Leaf Spots", "description": "Small purple spots enlarging to circular lesions with tan centers and dark brown margins."},
            {"title": "Bark Cankers", "description": "Sunken, reddish-brown areas on branches that enlarge and darken, eventually peeling or cracking."},
            {"title": "Fruit Mummification", "description": "Brown rotting originating at the calyx, rapidly turning the whole fruit black and shriveled."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"step": 1, "title": "Sanitary Pruning", "description": "Prune out dead or diseased wood at least 15 inches below the canker during dry winter days."},
                    {"step": 2, "title": "Mummy Removal", "description": "Remove all mummified fruit from the tree and orchard floor."}
                ],
                "chemical": {
                    "safetyMessage": "Protectant sprays during petal fall are critical.",
                    "products": [{"name": "Mancozeb", "strength": "Mild", "description": "Broad-spectrum protectant applied during early fruit development.", "dosage": "2g / Liter"}]
                },
                "preventive": ["Remove prunings from the orchard immediately", "Control fire blight (which creates dead wood for black rot to colonize)"]
            },
            "Medium": {
                "organic": [
                    {"step": 1, "title": "Copper Sulfate", "description": "Apply copper sulfate in late dormancy to suppress fungal overwintering."},
                    {"step": 2, "title": "Wound Protection", "description": "Seal major pruning wounds with organic grafting wax to prevent spore entry."}
                ],
                "chemical": {
                    "safetyMessage": "Always wear protective gear.",
                    "products": [{"name": "Thiophanate-methyl", "strength": "Medium", "description": "Systemic fungicide effective against Botryosphaeria species.", "dosage": "2g / Liter"}]
                },
                "preventive": ["Maintain tree vigor through proper fertilization", "Avoid drought stress"]
            },
            "High": {
                "organic": [
                    {"step": 1, "title": "Branch Amputation", "description": "Severely cankered scaffold branches must be removed entirely to save the main trunk."},
                    {"step": 2, "title": "Total Debris Burn", "description": "Burn all infected vegetative material immediately; do not compost."}
                ],
                "chemical": {
                    "safetyMessage": "Chemicals alone cannot cure wood cankers; surgical removal is mandatory.",
                    "products": [{"name": "Captan + Thiophanate-methyl", "strength": "Strong", "description": "Tank mix for maximum protection of surrounding healthy tissue.", "dosage": "3g / Liter"}]
                },
                "preventive": ["Implement a strict integrated pest management (IPM) program"]
            }
        }
    },
    "Apple___Cedar_apple_rust": {
        "common_name": "Cedar Apple Rust",
        "scientific_name": "Gymnosporangium juniperi-virginianae",
        "crop_type": "Apple",
        "overview": "This unique heteroecious rust fungus requires two hosts: apple trees and Eastern red cedar (Juniperus virginiana) to complete its complex two-year life cycle. It causes striking orange-yellow leaf spots and can severely stunt tree growth and fruit yield.",
        "causes": ["Proximity to infected Eastern red cedar trees (within 2-3 miles)", "Warm, rainy spring weather which triggers spore horns on cedar galls", "Wind dissemination of basidiospores"],
        "symptoms": [
            {"title": "Bright Orange Spots", "description": "Vivid yellow-orange lesions appearing on the upper surface of apple leaves in late spring."},
            {"title": "Tubular Aecia", "description": "Fringed, tube-like fungal structures forming on the underside of the leaf directly beneath the spots."},
            {"title": "Fruit Lesions", "description": "Raised, yellowish-orange spots on the calyx end of the fruit, causing dwarfing and malformation."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"step": 1, "title": "Host Removal", "description": "Cut down or remove galls from Eastern red cedars located within 200 yards of the orchard."},
                    {"step": 2, "title": "Resistant Varieties", "description": "In rust-prone areas, plant resistant varieties like Freedom, Liberty, or Redfree."}
                ],
                "chemical": {
                    "safetyMessage": "Apply protectants from pink bud stage through to 3 weeks after petal fall.",
                    "products": [{"name": "Mancozeb", "strength": "Mild", "description": "Surface protectant against windborne spores.", "dosage": "2g / Liter"}]
                },
                "preventive": ["Scout nearby cedars in early spring for brown galls", "Eradicate wild cedars near commercial orchards"]
            },
            "Medium": {
                "organic": [
                    {"step": 1, "title": "Sulfur Sprays", "description": "Apply wettable sulfur sequentially during the highest spore release windows (warm rains)."},
                    {"step": 2, "title": "Pruning", "description": "Remove heavily infected leaves to reduce stress on the young tree."}
                ],
                "chemical": {
                    "safetyMessage": "Use sterol inhibitors for kickback action.",
                    "products": [{"name": "Myclobutanil", "strength": "Medium", "description": "Highly effective systemic fungicide against rusts.", "dosage": "1.5g / Liter"}]
                },
                "preventive": ["Use weather-based disease forecasting models"]
            },
            "High": {
                "organic": [
                    {"step": 1, "title": "Copper Formulations", "description": "Use Bordeaux mixture cautiously (avoid fruit russeting) to halt massive spore germination."}
                ],
                "chemical": {
                    "safetyMessage": "Do not exceed maximum yearly applications of systemic fungicides.",
                    "products": [{"name": "Fenbuconazole", "strength": "Strong", "description": "Locally systemic triazole fungicide providing outstanding rust control.", "dosage": "2.5g / Liter"}]
                },
                "preventive": ["Coordinate with neighbors for regional cedar management"]
            }
        }
    },
    "Apple___healthy": {
        "common_name": "Healthy Apple Tree",
        "scientific_name": "Malus domestica",
        "crop_type": "Apple",
        "overview": "The apple tree displays vigorous, healthy foliage. Leaves are uniformly green, smooth, and fully expanded. There are no visual signs of fungal sporulation, bacterial cankers, or insect feeding damage.",
        "causes": ["Optimal soil pH (6.0-7.0)", "Adequate macro and micronutrients", "Proper dormant pruning", "Good orchard sanitation"],
        "symptoms": [],
        "treatments": {
            "Low": {"organic": [], "chemical": {"safetyMessage": "No active treatments required.", "products": []}, "preventive": ["Maintain routine dormant pruning for canopy light penetration", "Conduct annual soil tests"]}
        }
    },
    "Blueberry___healthy": {
        "common_name": "Healthy Blueberry",
        "scientific_name": "Vaccinium corymbosum",
        "crop_type": "Blueberry",
        "overview": "Healthy blueberry foliage displaying characteristic deep green, leathery leaves with no spotting, webbing, or chlorosis.",
        "causes": ["Optimal acidic soil pH (4.5-5.5)", "Proper peat/pine bark mulching", "Consistent, well-drained irrigation"],
        "symptoms": [],
        "treatments": {
            "Low": {"organic": [], "chemical": {"safetyMessage": "No active treatments required.", "products": []}, "preventive": ["Maintain soil acidity with elemental sulfur", "Use bird netting during fruiting"]}
        }
    },
    "Cherry_(including_sour)___Powdery_mildew": {
        "common_name": "Powdery Mildew",
        "scientific_name": "Podosphaera clandestina",
        "crop_type": "Cherry",
        "overview": "Powdery mildew is a ubiquitous fungal disease that primarily affects young cherry foliage and developing fruit. Unlike many fungi, it thrives in warm, dry weather with high humidity (but without free water). It overwinters in infected buds.",
        "causes": ["Warm days (20-27°C) and cool, humid nights", "Overwintered mycelium in dormant terminal buds", "Dense, shaded canopies with poor air flow"],
        "symptoms": [
            {"title": "White Mycelial Growth", "description": "Patches of white, powdery fungal growth on the underside of young leaves."},
            {"title": "Leaf Distortion", "description": "Leaves become narrow, distorted, curled upwards, and brittle."},
            {"title": "Fruit Infection", "description": "White powdery patches on unripe fruit, leading to stunted, unmarketable cherries with a dull finish."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"step": 1, "title": "Baking Soda Solution", "description": "Spray a solution of 1 tbsp baking soda and horticultural oil in 1 gallon of water."},
                    {"step": 2, "title": "Pruning", "description": "Prune out primary infected shoots (flag shoots) early in the season."}
                ],
                "chemical": {
                    "safetyMessage": "Begin applications at shuck-fall stage.",
                    "products": [{"name": "Wettable Sulfur", "strength": "Mild", "description": "Cost-effective protectant (avoid if temperatures exceed 30°C).", "dosage": "4g / Liter"}]
                },
                "preventive": ["Plant in full sun", "Open the canopy via dormant pruning"]
            },
            "Medium": {
                "organic": [
                    {"step": 1, "title": "Neem Oil", "description": "Apply cold-pressed neem oil to disrupt fungal cellular membranes (do not mix with sulfur)."},
                    {"step": 2, "title": "Bacillus subtilis", "description": "Use biological fungicides containing B. subtilis to outcompete the mildew."}
                ],
                "chemical": {
                    "safetyMessage": "Rotate FRAC codes.",
                    "products": [{"name": "Myclobutanil", "strength": "Medium", "description": "Sterol demethylation inhibitor (DMI) highly effective on powdery mildews.", "dosage": "1.5g / Liter"}]
                },
                "preventive": ["Avoid excess nitrogen fertilizer which promotes highly susceptible succulent growth"]
            },
            "High": {
                "organic": [
                    {"step": 1, "title": "Potassium Bicarbonate", "description": "Apply high-strength potassium bicarbonate sprays for eradicant action on heavy infections."}
                ],
                "chemical": {
                    "safetyMessage": "Use strobilurins with caution regarding resistance.",
                    "products": [{"name": "Trifloxystrobin", "strength": "Strong", "description": "Locally systemic strobilurin that halts spore production.", "dosage": "2g / Liter"}]
                },
                "preventive": ["Strictly adhere to a season-long preventative spray program next year"]
            }
        }
    },
    "Cherry_(including_sour)___healthy": {
        "common_name": "Healthy Cherry",
        "scientific_name": "Prunus avium / cerasus",
        "crop_type": "Cherry",
        "overview": "Healthy cherry foliage with vibrant, even-colored green leaves, normal uncurled margins, and robust shoot growth.",
        "causes": ["Good irrigation without waterlogging", "Sufficient nutrients (especially Nitrogen and Potassium)", "Proper orchard hygiene"],
        "symptoms": [],
        "treatments": {
            "Low": {"organic": [], "chemical": {"safetyMessage": "None required.", "products": []}, "preventive": ["Maintain weeding and organic mulching", "Monitor for aphids"]}
        }
    },
    "Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot": {
        "common_name": "Gray Leaf Spot",
        "scientific_name": "Cercospora zeae-maydis",
        "crop_type": "Corn",
        "overview": "Gray leaf spot (GLS) is one of the most yield-limiting diseases of corn worldwide. The fungus survives in corn residue left on the soil surface. Spores are windblown to lower leaves, progressing upwards during prolonged humid, overcast weather.",
        "causes": ["High humidity (over 90%) and prolonged leaf wetness (12+ hours)", "Conservation tillage/no-till practices leaving infected residue", "Continuous corn-on-corn rotation"],
        "symptoms": [
            {"title": "Initial Lesions", "description": "Small, tan spots surrounded by a yellow halo on lower leaves."},
            {"title": "Rectangular Lesions", "description": "Mature lesions become distinctively rectangular, restricted by leaf veins, turning gray as spores develop."},
            {"title": "Blighting", "description": "Multiple lesions coalesce, killing entire leaves and significantly reducing photosynthetic capability."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"step": 1, "title": "Crop Rotation", "description": "Rotate away from corn for at least 1-2 years (soybeans or alfalfa)."},
                    {"step": 2, "title": "Tillage", "description": "Use deep tillage to bury infected corn residue, accelerating its decay."}
                ],
                "chemical": {
                    "safetyMessage": "Fungicide may not be economically justified if occurring late in the grain fill.",
                    "products": []
                },
                "preventive": ["Select corn hybrids with high GLS resistance ratings", "Plant early to avoid late-season humidity peaks"]
            },
            "Medium": {
                "organic": [
                    {"step": 1, "title": "Biological Control", "description": "Apply Trichoderma-based biological agents to soil residue to speed decomposition."}
                ],
                "chemical": {
                    "safetyMessage": "Apply at VT (tasseling) or R1 (silking) stages for maximum ROI.",
                    "products": [{"name": "Azoxystrobin", "strength": "Medium", "description": "Strobilurin fungicide providing excellent preventative activity.", "dosage": "2g / Liter"}]
                },
                "preventive": ["Scout fields diligently starting two weeks before tasseling"]
            },
            "High": {
                "organic": [
                    {"step": 1, "title": "Early Harvest", "description": "Harvest for silage early if leaf destruction threatens stalk integrity and grain fill."}
                ],
                "chemical": {
                    "safetyMessage": "Use dual-action fungicides to manage heavy pressure.",
                    "products": [{"name": "Pyraclostrobin + Fluxapyroxad", "strength": "Strong", "description": "Premium dual-mode fungicide for both prevention and curative action.", "dosage": "3g / Liter"}]
                },
                "preventive": ["Implement strict conventional tillage if GLS is endemic"]
            }
        }
    },
    "Corn_(maize)___Common_rust_": {
        "common_name": "Common Rust",
        "scientific_name": "Puccinia sorghi",
        "crop_type": "Corn",
        "overview": "Common rust is driven by windblown urediniospores from southern climates moving northward each year. It thrives in cooler, humid environments. While visually striking, it rarely causes severe yield loss in modern resistant hybrids unless infection occurs very early.",
        "causes": ["Cool temperatures (16°C to 25°C)", "High relative humidity with frequent dews", "Wind currents from southern infected regions"],
        "symptoms": [
            {"title": "Pustule Formation", "description": "Small, circular to elongated, brick-red to cinnamon-brown pustules appearing on both upper and lower leaf surfaces."},
            {"title": "Epidermal Rupture", "description": "The pustules erupt through the leaf epidermis, releasing powdery, rust-colored spores."},
            {"title": "Late Season Blackening", "description": "As corn matures, pustules convert to producing teliospores, turning black."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"step": 1, "title": "Monitoring", "description": "Scout fields regularly; minor infections late in the season require no action."}
                ],
                "chemical": {
                    "safetyMessage": "Usually not economically necessary for low-level infections.",
                    "products": []
                },
                "preventive": ["Plant rust-resistant commercial hybrids"]
            },
            "Medium": {
                "organic": [
                    {"step": 1, "title": "Neem Oil", "description": "For small sweet corn patches, apply neem oil to inhibit spore attachment."}
                ],
                "chemical": {
                    "safetyMessage": "Apply if rust covers >3% of leaf area before silking.",
                    "products": [{"name": "Propiconazole", "strength": "Medium", "description": "Systemic triazole fungicide to stop rust development inside the leaf.", "dosage": "1.5ml / Liter"}]
                },
                "preventive": ["Avoid planting highly susceptible sweet corn varieties late in the season"]
            },
            "High": {
                "organic": [
                    {"step": 1, "title": "Stalk Management", "description": "Prepare for earlier harvest; severe rust can lead to stalk rot due to carbohydrate depletion."}
                ],
                "chemical": {
                    "safetyMessage": "Spray immediately if threshold is reached prior to tasseling.",
                    "products": [{"name": "Azoxystrobin + Propiconazole", "strength": "Strong", "description": "Broad spectrum systemic control.", "dosage": "2.5ml / Liter"}]
                },
                "preventive": ["Shift planting dates earlier to beat the migration of spores"]
            }
        }
    },
    "Corn_(maize)___Northern_Leaf_Blight": {
        "common_name": "Northern Leaf Blight (NLB)",
        "scientific_name": "Exserohilum turcicum",
        "crop_type": "Corn",
        "overview": "NLB is a serious fungal disease characterized by massive, cigar-shaped lesions. It can cause severe yield losses (up to 30% or more) if it establishes before or during the silking stage, heavily reducing the plant's photosynthetic capability.",
        "causes": ["Moderate temperatures (18°C to 27°C)", "Prolonged leaf wetness (6-18 hours)", "Spores overwintering in corn residue (no-till farming)"],
        "symptoms": [
            {"title": "Cigar-Shaped Lesions", "description": "Large (up to 6 inches long), elliptical, grayish-green to tan lesions."},
            {"title": "Spore Production", "description": "Under humid conditions, lesions produce dark, dusty fungal spores, giving them a dirty appearance."},
            {"title": "Leaf Blight", "description": "Lesions merge, causing the entire leaf to die and resembling frost damage."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"step": 1, "title": "Residue Management", "description": "Chop and bury stalks post-harvest to encourage decomposition."}
                ],
                "chemical": {
                    "safetyMessage": "Scout fields; apply only if lesions are found on the ear leaf prior to tasseling.",
                    "products": []
                },
                "preventive": ["Plant hybrids with high ratings for NLB resistance (major gene Ht1, Ht2, Ht3)"]
            },
            "Medium": {
                "organic": [
                    {"step": 1, "title": "Crop Rotation", "description": "Implement a 1 to 2-year rotation with a non-host crop (soybeans)."}
                ],
                "chemical": {
                    "safetyMessage": "Apply fungicide at VT/R1 stage.",
                    "products": [{"name": "Pyraclostrobin", "strength": "Medium", "description": "Effective strobilurin to protect the critical ear leaf.", "dosage": "2g / Liter"}]
                },
                "preventive": ["Avoid continuous corn in low-lying, humid fields"]
            },
            "High": {
                "organic": [
                    {"step": 1, "title": "Deep Plowing", "description": "Immediate deep plowing after harvest is mandatory to bury the massive inoculum load."}
                ],
                "chemical": {
                    "safetyMessage": "Double application may be required if pressure is extreme.",
                    "products": [{"name": "Fluxapyroxad + Pyraclostrobin", "strength": "Strong", "description": "SDHI and strobilurin combination for maximum residual control.", "dosage": "3g / Liter"}]
                },
                "preventive": ["Switch completely to highly resistant genetics"]
            }
        }
    },
    "Corn_(maize)___healthy": {
        "common_name": "Healthy Corn",
        "scientific_name": "Zea mays",
        "crop_type": "Corn",
        "overview": "Healthy corn stalks and foliage showing deep green coloration, vigorous vertical growth, and proper ear development without spots or lesions.",
        "causes": ["Proper Nitrogen-Phosphorus-Potassium (NPK) ratios", "Adequate soil moisture", "Good weed control"],
        "symptoms": [],
        "treatments": {
            "Low": {"organic": [], "chemical": {"safetyMessage": "None required.", "products": []}, "preventive": ["Maintain side-dressing of nitrogen at V6 stage"]}
        }
    },
    "Grape___Black_rot": {
        "common_name": "Grape Black Rot",
        "scientific_name": "Guignardia bidwellii",
        "crop_type": "Grape",
        "overview": "Black rot is arguably the most destructive fungal disease of grapes in warm, humid climates. It infects all green parts of the vine but causes the most devastating economic damage when it strikes developing berries, turning them into hard, black mummies.",
        "causes": ["Spring rains triggering ascospore release from overwintering mummies", "Warm temperatures (21°C - 27°C)", "Prolonged leaf wetness"],
        "symptoms": [
            {"title": "Leaf Lesions", "description": "Small, tan, circular spots with a dark brown border. Black pimple-like pycnidia form inside the spots."},
            {"title": "Shoot Lesions", "description": "Sunken, elliptical black cankers on young stems and tendrils."},
            {"title": "Berry Mummification", "description": "Berries turn light brown, then rapidly blacken, shrivel, and harden into raisin-like mummies."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"step": 1, "title": "Mummy Removal", "description": "During winter pruning, absolutely all mummified clusters must be removed from vines and the ground."}
                ],
                "chemical": {
                    "safetyMessage": "Protectant sprays are required from early shoot growth through veraison.",
                    "products": [{"name": "Mancozeb", "strength": "Mild", "description": "Excellent protectant against early leaf infections.", "dosage": "2.5g / Liter"}]
                },
                "preventive": ["Canopy management (leaf pulling) to maximize airflow and sunlight penetration"]
            },
            "Medium": {
                "organic": [
                    {"step": 1, "title": "Copper Formulations", "description": "Apply organic copper sprays preventatively every 7-10 days (requires frequent reapplication after rain)."}
                ],
                "chemical": {
                    "safetyMessage": "Use highly effective systemic fungicides during the critical bloom to pre-veraison window.",
                    "products": [{"name": "Myclobutanil", "strength": "Medium", "description": "Sterol inhibitor with excellent curative properties (up to 72 hours).", "dosage": "1.5g / Liter"}]
                },
                "preventive": ["Ensure excellent weed control under the trellis to lower humidity"]
            },
            "High": {
                "organic": [
                    {"step": 1, "title": "Cluster Thinning", "description": "Remove and burn heavily infected clusters immediately to save remaining fruit."}
                ],
                "chemical": {
                    "safetyMessage": "Rotate chemistries to prevent resistance. Do not apply DMIs exclusively.",
                    "products": [{"name": "Azoxystrobin + Difenoconazole", "strength": "Strong", "description": "Dual-action control for severe outbreaks.", "dosage": "3g / Liter"}]
                },
                "preventive": ["Establish a rigorous, uncompromising dormant sanitation program"]
            }
        }
    },
    "Grape___Esca_(Black_Measles)": {
        "common_name": "Esca (Black Measles)",
        "scientific_name": "Phaeomoniella chlamydospora & Phaeoacremonium aleophilum",
        "crop_type": "Grape",
        "overview": "Esca is a devastating grapevine trunk disease complex. The fungi colonize the vascular tissue (wood), slowly degrading it. It causes sudden vine collapse (apoplexy) or chronic leaf symptoms. There is no chemical cure once the wood is deeply infected.",
        "causes": ["Fungal entry through large winter pruning wounds", "Aging vines (typically over 10 years old)", "Environmental stress (drought or heat spikes)"],
        "symptoms": [
            {"title": "Tiger-Stripe Leaves", "description": "Leaves display interveinal chlorosis (yellowing/reddening) with necrotic brown centers, resembling tiger stripes."},
            {"title": "Black Measles", "description": "Small, dark, purplish spots (measles) covering the skin of the berries."},
            {"title": "Wood Necrosis", "description": "Cross-sections of the trunk reveal white rot surrounded by dark, necrotic vascular tissue."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"step": 1, "title": "Pruning Wound Protection", "description": "Paint large pruning cuts immediately with organic sealants or Trichoderma-based bio-paints."}
                ],
                "chemical": {
                    "safetyMessage": "Preventative chemical paste on wounds is the only chemical defense.",
                    "products": [{"name": "Thiophanate-methyl paste", "strength": "Mild", "description": "Apply to pruning wounds to block fungal entry.", "dosage": "Apply directly to cut"}]
                },
                "preventive": ["Delay pruning until late winter to minimize wound exposure times", "Disinfect pruning shears"]
            },
            "Medium": {
                "organic": [
                    {"step": 1, "title": "Trunk Surgery", "description": "Carefully scrape out the decayed spongy wood from the trunk until only healthy hard wood remains."}
                ],
                "chemical": {
                    "safetyMessage": "Foliar fungicides are completely ineffective against trunk diseases.",
                    "products": []
                },
                "preventive": ["Implement 'double pruning' techniques"]
            },
            "High": {
                "organic": [
                    {"step": 1, "title": "Trunk Renewal", "description": "Cut the vine trunk off near the ground (below the rot) and retrain a new sucker from the base."},
                    {"step": 2, "title": "Vine Uprooting", "description": "If apoplexy occurs, the entire vine must be uprooted and destroyed."}
                ],
                "chemical": {
                    "safetyMessage": "No chemical treatment available for severe wood degradation.",
                    "products": []
                },
                "preventive": ["Replant with certified disease-free grafted vines"]
            }
        }
    },
    "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)": {
        "common_name": "Isariopsis Leaf Spot (Grape Leaf Blight)",
        "scientific_name": "Pseudocercospora vitis",
        "crop_type": "Grape",
        "overview": "Isariopsis leaf spot primarily occurs late in the season, causing irregular necrotic lesions on the leaves. While usually less destructive than Black Rot, severe infections can cause premature defoliation, reducing winter hardiness and sugar accumulation.",
        "causes": ["High humidity and warm temperatures late in the growing season", "Inoculum surviving in fallen leaf debris", "Poor canopy management"],
        "symptoms": [
            {"title": "Irregular Brown Spots", "description": "Dark red to brown irregular spots on the upper leaf surface."},
            {"title": "Fungal Tufts", "description": "Dark, bristly tufts (coremia) of the fungus visible on the underside of the leaf spots."},
            {"title": "Premature Defoliation", "description": "Leaves dry out, become brittle, and drop off the vine weeks before natural autumn leaf fall."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"step": 1, "title": "Canopy Management", "description": "Remove leaves around the fruiting zone to improve air circulation and drying."}
                ],
                "chemical": {
                    "safetyMessage": "Usually controlled implicitly by fungicides used for Downy Mildew/Black Rot.",
                    "products": []
                },
                "preventive": ["Rake and destroy fallen leaves at the end of the season"]
            },
            "Medium": {
                "organic": [
                    {"step": 1, "title": "Copper Soap", "description": "Apply organic copper formulations if symptoms appear post-veraison."}
                ],
                "chemical": {
                    "safetyMessage": "Ensure adherence to pre-harvest intervals (PHI) when spraying late season.",
                    "products": [{"name": "Chlorothalonil", "strength": "Medium", "description": "Excellent broad-spectrum leaf spot control.", "dosage": "2g / Liter"}]
                },
                "preventive": ["Maintain good weed control to lower ground-level humidity"]
            },
            "High": {
                "organic": [
                    {"step": 1, "title": "Early Harvest Preparation", "description": "If defoliation is severe, consider harvesting slightly early if sugars are acceptable, to prevent fruit sunburn."}
                ],
                "chemical": {
                    "safetyMessage": "Use systemic strobilurins if disease is rapidly spreading.",
                    "products": [{"name": "Azoxystrobin", "strength": "Strong", "description": "Systemic action to protect remaining functional leaf area.", "dosage": "2.5g / Liter"}]
                },
                "preventive": ["Adjust the spray program next year to extend late-season protection"]
            }
        }
    },
    "Grape___healthy": {
        "common_name": "Healthy Grape Vine",
        "scientific_name": "Vitis vinifera",
        "crop_type": "Grape",
        "overview": "Grape vines displaying healthy green leaves, robust shoot growth, and clean clusters of berries.",
        "causes": ["Optimal dormant pruning", "Drip irrigation management", "Adequate macro nutrients"],
        "symptoms": [],
        "treatments": {
            "Low": {"organic": [], "chemical": {"safetyMessage": "None required.", "products": []}, "preventive": ["Maintain regular canopy shoot positioning (VSP)"]}
        }
    },
    "Orange___Haunglongbing_(Citrus_greening)": {
        "common_name": "Citrus Greening (HLB)",
        "scientific_name": "Candidatus Liberibacter asiaticus",
        "crop_type": "Orange",
        "overview": "Huanglongbing (HLB) is the most devastating citrus disease worldwide. It is a phloem-limited bacterial infection vectored by the Asian Citrus Psyllid. It chokes off the plant's vascular system, leading to rapid decline, bitter/green fruit, and tree death. THERE IS NO CURE.",
        "causes": ["Vector transmission via the Asian Citrus Psyllid (Diaphorina citri)", "Movement of infected nursery stock or grafting material"],
        "symptoms": [
            {"title": "Blotchy Mottle", "description": "Asymmetrical, blotchy yellowing on leaves that crosses the veins (unlike symmetrical nutritional deficiencies)."},
            {"title": "Yellow Shoots", "description": "Entire shoots turning yellow and dying back."},
            {"title": "Lopsided, Bitter Fruit", "description": "Fruit remains green at the stylar end, is lopsided, drops prematurely, and tastes incredibly bitter/salty."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"step": 1, "title": "Vector Control", "description": "Apply horticultural oils or insecticidal soaps rigorously to kill psyllid nymphs."},
                    {"step": 2, "title": "Enhanced Nutrition", "description": "Foliar feeding with micro-nutrients (Zinc, Manganese) to support the struggling vascular system."}
                ],
                "chemical": {
                    "safetyMessage": "Chemicals target the insect vector, not the bacteria inside the tree.",
                    "products": [{"name": "Imidacloprid", "strength": "Strong", "description": "Systemic insecticide applied as a soil drench to kill feeding psyllids.", "dosage": "Follow label instructions strictly"}]
                },
                "preventive": ["Only purchase certified disease-free citrus trees", "Scout weekly for psyllids"]
            },
            "Medium": {
                "organic": [
                    {"step": 1, "title": "Biological Control", "description": "Release Tamarixia radiata, a tiny parasitic wasp that specifically attacks the Asian Citrus Psyllid."}
                ],
                "chemical": {
                    "safetyMessage": "Foliar antibiotics (oxytetracycline) are being tested commercially but are highly restricted.",
                    "products": [{"name": "Thiamethoxam", "strength": "Strong", "description": "Systemic neonicotinoid for vector control.", "dosage": "Follow label"}]
                },
                "preventive": ["Coordinate area-wide psyllid spraying with neighboring groves"]
            },
            "High": {
                "organic": [
                    {"step": 1, "title": "Tree Eradication", "description": "The infected tree MUST be removed by the roots and destroyed to protect surrounding trees."}
                ],
                "chemical": {
                    "safetyMessage": "Eradication is the only legally and agriculturally sound option for severe HLB.",
                    "products": []
                },
                "preventive": ["Replant using psyllid-excluding screenhouses (CUPS system)"]
            }
        }
    },
    "Peach___Bacterial_spot": {
        "common_name": "Peach Bacterial Spot",
        "scientific_name": "Xanthomonas arboricola pv. pruni",
        "crop_type": "Peach",
        "overview": "Bacterial spot is a severe disease of peaches and nectarines, thriving in sandy soils and wet, windy environments. The bacteria overwinter in twig cankers and buds. It causes defoliation and renders the fruit unsellable due to severe cracking and pitting.",
        "causes": ["Wind-driven rain spreading bacteria from cankers to leaves/fruit", "High humidity and temperatures between 21°C and 30°C", "Sandy soils and nutrient stress"],
        "symptoms": [
            {"title": "Shot-Hole Leaves", "description": "Small, water-soaked leaf spots turn purple/black, then the dead tissue drops out, leaving 'shot holes'."},
            {"title": "Leaf Yellowing", "description": "Leaves turn yellow, especially at the tips, and drop prematurely, severely weakening the tree."},
            {"title": "Fruit Cracking", "description": "Deep, dark, pitted lesions on the fruit skin that crack open, often oozing gum."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"step": 1, "title": "Tree Vigor", "description": "Maintain excellent tree health. Weak trees are far more susceptible."},
                    {"step": 2, "title": "Windbreaks", "description": "Plant physical windbreaks (like tall grasses or trees) to prevent wind-driven rain and sand blasting."}
                ],
                "chemical": {
                    "safetyMessage": "Begin protective sprays at bud swell.",
                    "products": [{"name": "Copper Hydroxide", "strength": "Mild", "description": "Apply at low rates (to avoid phytotoxicity) from shuck-split onward.", "dosage": "1g / Liter"}]
                },
                "preventive": ["Plant highly resistant cultivars (e.g., Candor, Redhaven)"]
            },
            "Medium": {
                "organic": [
                    {"step": 1, "title": "Pruning", "description": "Prune out visible twig cankers during dry, dormant periods to reduce overwintering bacteria."}
                ],
                "chemical": {
                    "safetyMessage": "Antibiotics may be necessary if pressure is high.",
                    "products": [{"name": "Oxytetracycline", "strength": "Medium", "description": "Agricultural antibiotic; use strictly according to local regulations.", "dosage": "1.5g / Liter"}]
                },
                "preventive": ["Avoid excessive nitrogen fertilization, which promotes highly susceptible succulent growth"]
            },
            "High": {
                "organic": [
                    {"step": 1, "title": "Total Sanitation", "description": "Remove and burn all severely infected branches and fallen debris."}
                ],
                "chemical": {
                    "safetyMessage": "Rotate copper and antibiotics to prevent resistant bacterial strains.",
                    "products": [{"name": "Fixed Copper + Oxytetracycline", "strength": "Strong", "description": "Tank mix for maximum suppression during epidemic conditions.", "dosage": "Follow label limits strictly"}]
                },
                "preventive": ["If the orchard location is highly prone to bacterial spot, consider transitioning away from peaches"]
            }
        }
    },
    "Peach___healthy": {
        "common_name": "Healthy Peach",
        "scientific_name": "Prunus persica",
        "crop_type": "Peach",
        "overview": "Healthy peach tree foliage displaying bright, unblemished green leaves, smooth bark, and properly developing fruit.",
        "causes": ["Adequate spring pruning (open center system)", "Well-drained soil", "Proper thinning of fruit"],
        "symptoms": [],
        "treatments": {
            "Low": {"organic": [], "chemical": {"safetyMessage": "None required.", "products": []}, "preventive": ["Monitor for peach tree borer at the trunk base"]}
        }
    },
    "Pepper,_bell___Bacterial_spot": {
        "common_name": "Pepper Bacterial Spot",
        "scientific_name": "Xanthomonas campestris pv. vesicatoria",
        "crop_type": "Pepper",
        "overview": "Bacterial spot is one of the most destructive diseases of peppers in warm, wet climates. It affects leaves, stems, and fruits, causing severe defoliation that leaves peppers exposed to sunscald. The pathogen is seed-borne and survives in crop debris.",
        "causes": ["Infected seeds or transplants", "Overhead irrigation and splashing rain", "High temperatures (24°C - 30°C) with high humidity"],
        "symptoms": [
            {"title": "Water-Soaked Spots", "description": "Small, circular, water-soaked spots on the underside of leaves that eventually turn dark brown."},
            {"title": "Severe Defoliation", "description": "Leaves yellow rapidly and drop off in large numbers, halting plant growth."},
            {"title": "Fruit Scabs", "description": "Raised, blister-like, rough scabs on the surface of the pepper fruit."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"step": 1, "title": "Seed Treatment", "description": "Hot water treat pepper seeds (50°C for 25 minutes) before planting to kill seed-borne bacteria."},
                    {"step": 2, "title": "Watering Method", "description": "Switch entirely to drip irrigation to keep the foliage completely dry."}
                ],
                "chemical": {
                    "safetyMessage": "Preventative copper is the standard defense.",
                    "products": [{"name": "Copper Fungicide", "strength": "Mild", "description": "Apply as soon as transplants are established.", "dosage": "2g / Liter"}]
                },
                "preventive": ["Plant resistant varieties (look for X1, X2, X3 resistance genes)"]
            },
            "Medium": {
                "organic": [
                    {"step": 1, "title": "Sanitation", "description": "Avoid entering the pepper patch when leaves are wet to prevent mechanical spread of bacteria on clothes."}
                ],
                "chemical": {
                    "safetyMessage": "Combine copper with mancozeb for synergistic bactericidal activity.",
                    "products": [{"name": "Copper + Mancozeb", "strength": "Medium", "description": "Tank mix significantly improves the efficacy of copper against Xanthomonas.", "dosage": "3g / Liter combined"}]
                },
                "preventive": ["Remove weeds (like nightshades) that can harbor the bacteria"]
            },
            "High": {
                "organic": [
                    {"step": 1, "title": "Plant Eradication", "description": "Pull out and carefully bag/burn heavily infected plants to save the rest of the field."}
                ],
                "chemical": {
                    "safetyMessage": "Copper-resistant strains are common; if copper fails, chemical options are limited.",
                    "products": [{"name": "Actigard (Acibenzolar-S-methyl)", "strength": "Strong", "description": "Plant defense activator (induces systemic acquired resistance).", "dosage": "Follow label strictly"}]
                },
                "preventive": ["Enforce a strict 2-3 year crop rotation away from peppers and tomatoes"]
            }
        }
    },
    "Pepper,_bell___healthy": {
        "common_name": "Healthy Bell Pepper",
        "scientific_name": "Capsicum annuum",
        "crop_type": "Pepper",
        "overview": "Healthy bell pepper plants showing bushy, lush green foliage, sturdy stems, and glossy, spot-free developing peppers.",
        "causes": ["Warm soil temperatures", "Consistent drip irrigation", "Balanced calcium and phosphorus"],
        "symptoms": [],
        "treatments": {
            "Low": {"organic": [], "chemical": {"safetyMessage": "None required.", "products": []}, "preventive": ["Apply organic mulch to stabilize soil moisture and prevent blossom end rot"]}
        }
    },
    "Potato___Early_blight": {
        "common_name": "Potato Early Blight",
        "scientific_name": "Alternaria solani",
        "crop_type": "Potato",
        "overview": "Early blight is a very common fungal disease of potatoes, typically affecting older, senescing leaves first. Despite its name, it often peaks mid-to-late season. It reduces yield by destroying photosynthetic tissue and can cause dry rot on tubers.",
        "causes": ["Alternating periods of wet and dry weather", "Nitrogen or nutritional stress in the plant", "Spores splashing up from infected soil debris"],
        "symptoms": [
            {"title": "Target-Board Spots", "description": "Dark brown to black lesions on older leaves featuring distinct concentric rings (like a target)."},
            {"title": "Yellow Halos", "description": "A prominent yellow chlorotic halo surrounds the lesions."},
            {"title": "Tuber Lesions", "description": "Dark, sunken, leathery, and dry lesions on the surface of the potato tuber."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"step": 1, "title": "Nutrition", "description": "Maintain optimal nitrogen and fertility levels; early blight aggressively attacks stressed, hungry plants."},
                    {"step": 2, "title": "Mulching", "description": "Apply a thick layer of straw mulch to prevent soil splashing onto lower leaves."}
                ],
                "chemical": {
                    "safetyMessage": "Begin protectant sprays when vines close between rows.",
                    "products": [{"name": "Chlorothalonil", "strength": "Mild", "description": "Excellent, cost-effective protectant fungicide.", "dosage": "2g / Liter"}]
                },
                "preventive": ["Use certified disease-free seed potatoes", "Practice 3-year crop rotations"]
            },
            "Medium": {
                "organic": [
                    {"step": 1, "title": "Lower Leaf Pruning", "description": "In small garden plots, remove heavily infected lower leaves to slow upward progression."}
                ],
                "chemical": {
                    "safetyMessage": "Rotate chemical classes as Alternaria is prone to developing resistance.",
                    "products": [{"name": "Azoxystrobin", "strength": "Medium", "description": "Strobilurin fungicide highly effective against early blight.", "dosage": "2g / Liter"}]
                },
                "preventive": ["Water early in the morning so leaves dry quickly"]
            },
            "High": {
                "organic": [
                    {"step": 1, "title": "Vine Desiccation", "description": "If severe defoliation occurs near harvest, kill/cut the vines to prevent spores from washing down into the tubers."}
                ],
                "chemical": {
                    "safetyMessage": "Tank mix systemic and protectant fungicides.",
                    "products": [{"name": "Boscalid + Pyraclostrobin", "strength": "Strong", "description": "Premium dual-action fungicide for severe pressure.", "dosage": "3g / Liter"}]
                },
                "preventive": ["Ensure tubers are fully mature with set skins before digging to prevent infection through wounds"]
            }
        }
    },
    "Potato___Late_blight": {
        "common_name": "Potato Late Blight",
        "scientific_name": "Phytophthora infestans",
        "crop_type": "Potato",
        "overview": "Late blight is the infamous water mold (oomycete) responsible for the Irish Potato Famine. It is a highly contagious, rapidly spreading pathogen that can destroy an entire potato field within days under cool, wet conditions.",
        "causes": ["Cool temperatures (10°C - 20°C) with continuous high humidity or rain", "Infected seed tubers", "Spores blowing in from neighboring infected fields"],
        "symptoms": [
            {"title": "Water-Soaked Lesions", "description": "Large, pale green to dark brown water-soaked spots appearing quickly on leaves and stems."},
            {"title": "White Fuzzy Mold", "description": "Under humid conditions, a distinct white, fuzzy sporulation ring appears on the underside of the leaf lesions."},
            {"title": "Tubers Rot", "description": "Tubers develop a shallow, reddish-brown, granular dry rot that often invites soft rot bacteria, turning the potato to mush."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"step": 1, "title": "Cull Piles", "description": "Destroy all potato cull piles and volunteer potatoes in the spring, as they harbor the overwintering pathogen."}
                ],
                "chemical": {
                    "safetyMessage": "Preventative spraying is absolutely mandatory if late blight is reported in your region.",
                    "products": [{"name": "Mancozeb or Chlorothalonil", "strength": "Mild", "description": "Standard protectant barrier. Must be applied before spores arrive.", "dosage": "2.5g / Liter"}]
                },
                "preventive": ["Plant certified seed tubers only", "Monitor regional blight warning systems"]
            },
            "Medium": {
                "organic": [
                    {"step": 1, "title": "Copper Sprays", "description": "Apply organic copper formulations frequently. Note: Copper is a protectant, not a cure."}
                ],
                "chemical": {
                    "safetyMessage": "Switch to locally systemic oomycete-specific fungicides.",
                    "products": [{"name": "Cymoxanil + Mancozeb", "strength": "Medium", "description": "Provides short-term kickback activity against new infections.", "dosage": "2.5g / Liter"}]
                },
                "preventive": ["Hill up the soil well around the base of the plants to protect tubers from washing spores"]
            },
            "High": {
                "organic": [
                    {"step": 1, "title": "Immediate Destruction", "description": "Kill the vines (flame weeding or cutting) IMMEDIATELY to save the tubers. Do not wait."}
                ],
                "chemical": {
                    "safetyMessage": "Epidemic conditions require extremely potent, specific chemistries.",
                    "products": [{"name": "Mefenoxam (Ridomil)", "strength": "Strong", "description": "Highly systemic, but resistance is common. Often tank-mixed with protectants.", "dosage": "Follow label emergency protocols"}]
                },
                "preventive": ["Wait at least 2-3 weeks after vines are completely dead before harvesting tubers"]
            }
        }
    },
    "Potato___healthy": {
        "common_name": "Healthy Potato",
        "scientific_name": "Solanum tuberosum",
        "crop_type": "Potato",
        "overview": "Healthy potato plants displaying vigorous, full green vine growth without leaf spotting, yellowing, or wilting.",
        "causes": ["Certified disease-free seed", "Well-drained, loose loamy soil", "Proper hilling techniques"],
        "symptoms": [],
        "treatments": {
            "Low": {"organic": [], "chemical": {"safetyMessage": "None required.", "products": []}, "preventive": ["Scout for Colorado potato beetles", "Maintain consistent soil moisture for even tuber growth"]}
        }
    },
    "Tomato___Early_blight": {
        "common_name": "Tomato Early Blight",
        "scientific_name": "Alternaria solani",
        "crop_type": "Tomato",
        "overview": "Early blight is the most common fungal disease of tomatoes. It starts on the lower, older leaves and works its way up the plant. The fungus survives the winter in infected plant debris in the soil.",
        "causes": ["Warm temperatures (24-29°C) combined with high humidity", "Overcrowded planting reducing airflow", "Rain splashing soil-borne spores onto lower leaves"],
        "symptoms": [
            {"title": "Concentric Rings", "description": "Dark brown leaf spots showing distinct concentric rings (target pattern)."},
            {"title": "Yellowing Upward", "description": "The tissue around the spots turns yellow. The lower leaves dry up and drop off, exposing fruit to sunscald."},
            {"title": "Stem and Fruit", "description": "Dark, sunken lesions can form on the stems, and leathery black spots may form near the stem end of the fruit."}
        ],
        "treatments": {
            "Low": {
                "organic": [
                    {"step": 1, "title": "Mulching", "description": "Apply a thick layer of organic mulch (straw or leaves) to prevent soil from splashing onto the plant."},
                    {"step": 2, "title": "Pruning", "description": "Remove the bottom 12 inches of leaves to improve airflow and separate leaves from soil."}
                ],
                "chemical": {
                    "safetyMessage": "Begin preventative sprays when the first fruits are formed.",
                    "products": [{"name": "Chlorothalonil", "strength": "Mild", "description": "Protective contact fungicide.", "dosage": "2g / Liter"}]
                },
                "preventive": ["Space plants generously", "Use drip irrigation instead of overhead sprinklers"]
            },
            "Medium": {
                "organic": [
                    {"step": 1, "title": "Copper Soap", "description": "Spray organic liquid copper soap every 7-10 days."}
                ],
                "chemical": {
                    "safetyMessage": "Use systemic fungicides if the disease is climbing rapidly.",
                    "products": [{"name": "Mancozeb", "strength": "Medium", "description": "Broad-spectrum control.", "dosage": "2g / Liter"}]
                },
                "preventive": ["Stake or cage plants to keep them completely off the ground"]
            },
            "High": {
                "organic": [
                    {"step": 1, "title": "Plant Removal", "description": "At the end of the season, pull out the entire plant and roots. Do not compost."}
                ],
                "chemical": {
                    "safetyMessage": "Observe all pre-harvest intervals.",
                    "products": [{"name": "Azoxystrobin", "strength": "Strong", "description": "Potent control for advanced infections.", "dosage": "2.5g / Liter"}]
                },
                "preventive": ["Practice a strict 3-year crop rotation (do not plant potatoes, peppers, or tomatoes in the same spot)"]
            }
        }
    }
}

def clean_crop_name(name):
    if not name:
        return ""
    name = name.lower()
    name = name.split("_(")[0]  # cherry_(including_sour) -> cherry
    name = name.replace("_", " ").strip()
    return name

def get_disease_info(class_name, severity="Medium"):
    if severity == "Moderate":
        severity = "Medium"
        
    parts = class_name.split("___")
    crop = parts[0]
    disease = parts[1].replace("_", " ") if len(parts) > 1 else "Unknown Disease"
    crop_cleaned = clean_crop_name(crop).title()
    
    info = DISEASE_KNOWLEDGE.get(class_name)
    
    if not info:
        disease_cleaned = disease.title()
        is_healthy = "healthy" in disease.lower()
        
        if is_healthy:
            info = {
                "common_name": "Healthy State",
                "scientific_name": "N/A",
                "crop_type": crop_cleaned,
                "overview": f"The {crop_cleaned} plant tissue exhibits healthy, vibrant green coloration with robust cell structures and no active fungal or bacterial spots.",
                "causes": ["Sufficient nitrogen and soil aeration", "Regular watering schedules", "Favorable ambient microclimate"],
                "symptoms": [],
                "treatments": {
                    "Low": {"organic": [], "chemical": {"safetyMessage": "No chemical treatments are needed for healthy crops.", "products": []}, "preventive": ["Maintain regular irrigation", "Apply balanced fertilizers"]},
                    "Medium": {"organic": [], "chemical": {"safetyMessage": "No chemical treatments are needed for healthy crops.", "products": []}, "preventive": ["Maintain regular irrigation"]},
                    "High": {"organic": [], "chemical": {"safetyMessage": "No chemical treatments are needed for healthy crops.", "products": []}, "preventive": ["Maintain regular irrigation"]}
                }
            }
        else:
            info = {
                "common_name": disease_cleaned,
                "scientific_name": f"{disease.replace(' ', '_').title()} phytopathogen",
                "crop_type": crop_cleaned,
                "overview": f"{disease_cleaned} is a tissue-damaging infectious disease impacting the growth cycle and vascular pathways of {crop_cleaned} crops.",
                "causes": [
                    "Warm stagnant air and elevated humidity",
                    "Overcrowded canopy limiting foliage drying rates",
                    "Spores overwintering in unmanaged ground debris"
                ],
                "symptoms": [
                    {"title": "Necrotic Spotting", "description": f"Superficial brown spots and lesions spreading across the upper leaf surface."},
                    {"title": "Chlorotic Halos", "description": "Foliar chlorosis forming bright yellow rings surrounding the dead necrotic centers."},
                    {"title": "Lower Defoliation", "description": "Lower leaves turn dry, crispy, and fall off prematurely due to severe tissue damage."}
                ],
                "treatments": {
                    "Low": {
                        "organic": [
                            {"step": 1, "title": "Manual Pruning", "description": "Clip off and safely dispose of the few bottom leaves that display spotting."}
                        ],
                        "chemical": {
                            "safetyMessage": "Fungicide application is optional at this early stage. Monitor closely.",
                            "products": []
                        },
                        "preventive": ["Improve canopy air circulation", "Clear organic debris around base"]
                    },
                    "Medium": {
                        "organic": [
                            {"step": 1, "title": "Neem Oil Shield", "description": "Mix 5ml cold-pressed organic neem oil per liter of water. Spray thoroughly."}
                        ],
                        "chemical": {
                            "safetyMessage": "Always wear thick protective gloves and goggles.",
                            "products": [{"name": "Chlorothalonil Protective Fungicide", "strength": "Medium", "description": "Multi-site contact fungicide.", "dosage": "2g / Liter"}]
                        },
                        "preventive": ["Switch to soil-level drip lines", "Sanitize all harvesting tools"]
                    },
                    "High": {
                        "organic": [
                            {"step": 1, "title": "Severe Defoliation", "description": "Uproot and burn heavily deteriorated individual plants to shield neighboring crops."}
                        ],
                        "chemical": {
                            "safetyMessage": "Adhere strictly to the pre-harvest interval instructions.",
                            "products": [{"name": "Mancozeb + Metalaxyl", "strength": "Strong", "description": "Dual action systemic fungicide.", "dosage": "3g / Liter"}]
                        },
                        "preventive": ["Enforce a strict 3-year crop rotation schedule"]
                    }
                }
            }
  
    treatment_data = info.get("treatments", {}).get(severity, {})
    if not treatment_data and "treatments" in info:
        treatment_data = info["treatments"].get("Medium", {})
  
    return {
        "common_name": info.get("common_name", "Unknown Disease"),
        "scientific_name": info.get("scientific_name", "N/A"),
        "crop_type": info.get("crop_type", crop_cleaned),
        "overview": info.get("overview", "A plant tissue infection requiring active management."),
        "causes": info.get("causes", ["Excess moisture", "Warm temperatures"]),
        "symptoms": info.get("symptoms", []),
        "organic_treatment": treatment_data.get("organic", []),
        "chemical_treatment": treatment_data.get("chemical", {}),
        "prevention": treatment_data.get("preventive", ["Monitor crop health regularly."])
    }

def get_all_diseases(db=None):
    results = {}
    for class_name, info in DISEASE_KNOWLEDGE.items():
        if "healthy" not in class_name.lower():
            results[class_name] = info
    return results
