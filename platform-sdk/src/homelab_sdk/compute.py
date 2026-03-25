from typing import Dict, Any

def compute_tier(size: str = "base") -> Dict[str, Any]:
    # strict limits tailored to the 32gb node constraint.
    tiers = {
        "micro": {"cpu": "500m", "mem": "512Mi"},
        "base": {"cpu": "1", "mem": "2Gi"},
        "heavy": {"cpu": "2", "mem": "4Gi"},
        "max": {"cpu": "4", "mem": "8Gi"} 
    }
    
    if size not in tiers:
        raise ValueError(f"invalid compute tier. allowed: {list(tiers.keys())}")
        
    alloc = tiers[size]
    
    return {
        "dagster-k8s/config": {
            "container_config": {
                "resources": {
                    "requests": {"cpu": alloc["cpu"], "memory": alloc["mem"]},
                    "limits": {"cpu": alloc["cpu"], "memory": alloc["mem"]}
                }
            }
        }
    }