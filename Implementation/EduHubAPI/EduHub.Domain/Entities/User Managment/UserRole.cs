using System;
using System.Collections.Generic;
using System.Text;

namespace EduHub.Domain.Entities.User_Managment
{
    public class UserRole
    {
        public int UserId { get; set; }
        public int RoleId { get; set; }

        public User User { get; set; } = null!;
        public Role Role { get; set; } = null!;
    }
}
